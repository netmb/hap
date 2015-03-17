#!/bin/bash

function showBanner {
  echo -e "################################################################################"
  echo -e $1
  echo -e "################################################################################\n"
}

clear
showBanner "HAP-Installation requires the following steps:\n\n
1. Install required DEB-Packages\n 
2. Create 'HAP'-account\n
3. Fetch latest HAP-SVN-Version to /opt/hap\n
4. Create HAP-Database\n
5. Modify initd\n
\n
Press any key to start the installation...
"
read

clear
showBanner "1. Install required DEB-Packages"
apt-get install perl git mysql-server avr-libc gcc-avr binutils-avr make libcatalyst-perl libcatalyst-view-tt-perl libjson-xs-perl libpoe-perl libcatalyst-modules-extra-perl libcatalyst-modules-perl \
libimage-size-perl libarchive-zip-perl libset-crontab-perl libschedule-cron-perl libdevice-serialport-perl libparams-util-perl libterm-readkey-perl


clear
showBanner "2. Create 'HAP'-account"
adduser hap

clear
showBanner "3. Fetch latest HAP-SVN-Version to /opt/hap and install base-packages"
cd /opt
git clone https://github.com/netmb/hap.git
dpkg -i /opt/hap/var/deb/libcatalyst-plugin-authentication-store-dbic-perl_0.10-1_all.deb
dpkg -i /opt/hap/var/deb/libpoe-component-easydbi-perl_1.23-1_all.deb
dpkg -i /opt/hap/var/deb/libschedule-cron-events-perl_1.8-1_all.deb
chown hap:hap -R /opt/hap

clear
showBanner "4. Create HAP-Database\n\n
Specify an mysql-user-account who has the permission to create a database and user.\n
Usually this is 'root'\n"
read -e -p "MySQL-User [root]: " mysqlUser
if [ "$mysqlUser" == "" ]; then
  mysqlUser="root"
fi
mysql < /opt/hap/etc/hap.sql -u $mysqlUser -p

clear
showBanner "5. Link System-files\n"
cp /opt/hap/etc/init.d/* /etc/init.d/
update-rc.d hap-mp defaults 99
update-rc.d hap-scheduler defaults 99
update-rc.d hap-configserver defaults 99

showBanner "6. Starting HAP-Services"
/etc/init.d/hap-mp start
/etc/init.d/hap-scheduler start
/etc/init.d/hap-configserver start