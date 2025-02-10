#/!bin/bash

# -*- mode: c; c-basic-offset: 4; indent-tabs-mode: nil; -*-
# vim:expandtab:shiftwidth=4:tabstop=4:

function error
{
    echo "ERROR: $*"
    log_cleanup
    exit 1
}

function copytool_setup
{
    # terminate previous copytool
    curr_ct_pid=$(pgrep -f hsm_copytool_posix)
    [ $? -ne 0 ] || kill $curr_ct_pid

    # start a new one
    hsm_copytool_posix --hsm_root=/tmp --archive 0 &
    CT_PID=$!
}

function copytool_cleanup
{
    kill $CT_PID
}


function log_setup
{
    # code change from read /proc/fs/lustre/mdd/lustre-MDT0000/changelog_users
    # to 'lctl get_param' command, previous one already deprecated in new lustre version
    cl_readers=`lctl get_param mdd.lustre-MDT0000.changelog_users | awk '{print $1}' | grep cl`
    for id in $cl_readers; do
        lctl --device lustre-MDT0000 changelog_deregister $id
    done

    # changelog setup
    lctl --device lustre-MDT0000 changelog_register
    if [ "$?" -ne 0 ]
    then
        error "Cannot register changelog user"
    fi

    cl_readers=`lctl get_param mdd.lustre-MDT0000.changelog_users | awk '{print $1}' | grep cl`
    CLID=`echo $cl_readers | tail -f -n 1 | awk '{print $1}'`
    echo "changelog user id is $CLID"

    lctl set_param mdd.*.changelog_mask "CREAT UNLNK TRUNC TIME HSM SATTR" \
        || error "Error setting changelog mask"

    # initial cleanup (to make sure there are no previous records)
    lfs changelog_clear lustre $CLID 0
}

function log_cleanup
{
    # deregister changelog client after clearing its records
    # free up all of old changelog records
    lfs changelog_clear lustre $CLID 0
    lctl --device lustre-MDT0000 changelog_deregister $CLID
}

function test1
{
    echo "1) create and write file"
    # write file
    dd if=/dev/zero of=/mnt/lustre/file.1 bs=1M count=10

    echo "Log after create:"
    # read changelogs and clear all
    lfs changelog lustre
    echo "lfs changelog_clear lustre $CLID 0"
    lfs changelog_clear lustre $CLID 0

    echo "2) archive file"
    # archive file
    lfs hsm_archive /mnt/lustre/file.1

    # wait for copy completion (wait for HSM event in changelog)
    while (( 1 )); do
        hsm_cnt=$(lfs changelog lustre-MDT0000 | grep HSM | wc -l)
        [ $hsm_cnt -eq 1 ] && break
        sleep 0.1
    done

    echo "3) read chglog and get file state"
    # for each changelog event, get entry state and clear the record
    # (reproduces PolicyEngine behavior)
    for i in `lfs changelog lustre-MDT0000 | grep -v MARK | awk '{print $1}'`; do
        line=$(lfs changelog lustre-MDT0000 | egrep "^$i ")
        echo "LOG RECORD: $line"
        FID=$(echo $line | awk '{print $6}' | cut -d '=' -f 2)
        echo "FID=$FID"
        # get state for this entry
        lfs hsm_state "/mnt/lustre/.lustre/fid/$FID" > /dev/null \
            || error "Cannot stat /mnt/lustre/.lustre/fid/$FID"
        # acknownledge the record
        echo "lfs changelog_clear lustre-MDT0000 $CLID $i"
        lfs changelog_clear lustre-MDT0000 $CLID $i
    done

    # at this point, the log should be empty...
    echo "last cleared log record is $i"
    echo "Current log content:"
    lfs changelog lustre-MDT0000
    echo "=========================="

    echo "4) Release"

    # now release the file
    lfs hsm_release /mnt/lustre/file.1

    echo "Log content after hsm_release:"
    lfs changelog lustre-MDT0000
    echo "=========================="
}

rm -rf /mnt/lustre/*

# comment by qingyun_fu
# notice, from code, it can only run with following condition
# 1. fs named with 'lustre'
# 2. fs mount in '/mnt/lustre', it means lustre server also act as lustre client

#copytool_setup
log_setup
test1
log_cleanup
#copytool_cleanup

rm -rf /mnt/lustre/*
