#!/bin/bash

# Package versions
NAGIOS_VERSION="4.0.7"
PLUGINS_VERSION="2.0.3"
NRPE_VERSION="2.15"

apt-get update
apt-get -y install build-essential apache2 apache2-utils \
	libapache2-mod-php5 libgd2-xpm-dev libssl-dev

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
wget_unzip http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-${NAGIOS_VERSION}.tar.gz
wget_unzip http://www.nagios-plugins.org/download/nagios-plugins-${PLUGINS_VERSION}.tar.gz
wget_unzip http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-2.x/nrpe-${NRPE_VERSION}/nrpe-${NRPE_VERSION}.tar.gz

##################
# Create accounts

useradd nagios
groupadd nagcmd
usermod -G nagcmd nagios
usermod -a -G nagios www-data
usermod -a -G nagcmd www-data

##################
# Install

# Nagios
cd $download/nagios-${NAGIOS_VERSION}
./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/sites-available
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf

mkdir -p /usr/local/nagios/var/spool/checkresults
chown -R nagios:nagios /usr/local/nagios

# Plugins
cd $download/nagios-plugins-${PLUGINS_VERSION}
./configure
make
make install

# NRPE
cd $download/nrpe-${NRPE_VERSION}
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make
make install
make install-daemon-config
cp init-script.debian /etc/init.d/nrpe
chmod 755 /etc/init.d/nrpe

###########
# Configure

# Nagios lets you place all the configuration files in directories,
# Ref http://users.telenet.be/mydotcom/howto/nagios/config.html.
lin="cfg_dir=/usr/local/nagios/etc/servers"
sed -i "s|#$lin|$lin|" /usr/local/nagios/etc/nagios.cfg
mkdir -p /usr/local/nagios/etc/servers

# Dropping in sample config file
cp /vagrant/sample_check.cfg /usr/local/nagios/etc/servers/client.cfg

# Apache
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios
chown nagios:nagios /usr/local/nagios/etc/htpasswd.users
a2ensite nagios
a2enmod cgi

a2enmod rewrite
cat <<-EOF >> /etc/apache2/apache2.conf
# Send users to Nagios by default.
RedirectMatch ^/$ /nagios
EOF


###########
# Start

update-rc.d nrpe defaults 99
update-rc.d nagios defaults 99
service apache2 restart
service nrpe start
service nagios start

echo "DONE"
echo "Omitted: Configuring the Nagios Admin email (/usr/local/nagios/etc/objects/contacts.cfg)"
echo "Omitted: Optional: Restrict Access by IP Address"
echo "The nagios admin username/password is nagiosadmin/nagios"
