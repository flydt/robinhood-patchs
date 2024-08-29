#!/bin/bash
#
# dpkg_precheck.sh
# used to check build packages dependency for ubuntu

check_deb_pkg() {
	# get deb package name
	pkg_name=$1

	dpkg -l $pkg_name 1> /dev/null 2>&1
	if [ "$?" -ne 0 ]
	then
		echo package \'$pkg_name\' not found
		echo please run \'sudo apt install $pkg_name\' to install package
		return 1
	else
		#
		# need check further, because 'dpkg -l' command will return 0 if
		# pkg ever installed but uninstalled now with output as:
		# 
		# un  libglib2.0-dev <none>       <none>       (no description available)
		#
		# package installed with output as:
		# ii  libglib2.0-dev:amd64 2.64.6-1~ubuntu20.04.7 amd64        Development files for the GLib library
		#
		pkg_state=`dpkg -l $pkg_name | grep -w $pkg_name | awk '{print $1}'`
		if [ "$pkg_state" == "ii" ]
		then
			echo found package \'$pkg_name\'
			return 0
		else
			echo found package \'$pkg_name\' uninstalled
			echo please run \'sudo apt install $pkg_name\' to install package
			return 1
		fi
	fi
}

uname -a | grep ubuntu 1> /dev/null 2>&1
is_ubuntu=$?
if [ $is_ubuntu -eq 0 ]
then
	pkgs_dep=(libjemalloc-dev libglib2.0-dev mysql-server libmysqlclient-dev bison libattr1-dev)
	for pkg_name in ${pkgs_dep[@]};
	do
		echo check if \'$pkg_name\' installed
		check_deb_pkg $pkg_name
		if [ "$?" -ne 0 ]
		then
			exit 1
		fi
	done
fi

wdir=$(dirname $(readlink -m "$0"))
if [ $is_ubuntu -eq 0 ]
then
	# prepare robinhood.spec.in file for build in ubuntu
	cp $wdir/robinhood.spec.in.ubuntu $wdir/robinhood.spec.in
else
	# prepare robinhood.spec.in file for build in RHEL/CentOS/AlmaLinux/openEuler
	cp $wdir/robinhood.spec.in.rhel $wdir/robinhood.spec.in
fi

exit 0
