#!/usr/bin/bash
#
# prepare robinhood configure directory

# create target directory for policy file
mkdir -p /etc/robinhood.d/includes/
mkdir -p /etc/robinhood.d/templates/

# install policy file dependency
install -m 644 doc/templates/includes/*.inc /etc/robinhood.d/includes/
install -m 644 doc/templates/*.conf /etc/robinhood.d/templates/

# setup default environment variable
install -m 644 scripts/sysconfig_robinhood /etc/sysconfig/robinhood

# setup library
install -m 644 scripts/ld.so.robinhood.conf /etc/ld.so.conf.d/robinhood.conf
ldconfig

# install service
install -m 444 scripts/robinhood.service /usr/lib/systemd/system/robinhood.service
systemctl enable robinhood
