#!/bin/bash

wdir=$(dirname $(readlink -m "$0"))
arch=$(uname -i)
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)

make rpms -j$cpus
cd $wdir/rpms/RPMS/$arch/
find . -type f | grep -e webgui -e debug | xargs rm -f
find . -type f | xargs fakeroot alien --scripts
cd $wdir
