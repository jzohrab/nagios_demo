#!/bin/bash

# Package versions
NAGIOS_VERSION="4.0.7"
PLUGINS_VERSION="2.0.3"
NRPE_VERSION="2.15"

apt-get update
apt-get install -y libssl-dev

download="/tmp/download"
mkdir -p $download


##################
# Get packages

cd $download
wget_unzip() {
    echo Downloading $1
    wget $1 -O f.tar.gz
    tar -xzf f.tar.gz
}
wget_unzip http://www.nagios-plugins.org/download/nagios-plugins-${PLUGINS_VERSION}.tar.gz
wget_unzip http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-2.x/nrpe-${NRPE_VERSION}/nrpe-${NRPE_VERSION}.tar.gz

useradd nagios


##################
# Install

cd $download/nagios-plugins-${PLUGINS_VERSION}
./configure
make
make install

cd $download/nrpe-${NRPE_VERSION}
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make
make install
make install-daemon-config


###########
# Configure
# Note using the private IPs specified in the vagrantfile.
config=/usr/local/nagios/etc/nrpe.cfg
rootfilesysname=`df -h / | grep ^/dev | awk '{ print $1 }'`
sed -i 's/^allowed_hosts.*/allowed_hosts=127.0.0.1,192.168.33.10/' $config
sed -i 's/#server_address.*/server_address=192.168.33.11/' $config
sed -i "s|/dev/hda1|$rootfilesysname|" $config


###########
# Start

cp init-script.debian /etc/init.d/nrpe
chmod 755 /etc/init.d/nrpe
update-rc.d nrpe defaults 99
service nrpe start
