#!/bin/bash

source checkSuccess.sh

# check if script is executed inside the scripts folder
current_dir=${PWD##*/}
if [[ "$current_dir" != "scripts" ]]; then
    echo "The script has to be executed within the <git-velux_on_raspberry>/scripts folder!"
    exit 1
fi


# Install apache and PHP
apt-get install -y apache2 php5
checkSuccess $? "Install Apache and PHP"

# install taskspooler
apt-get install -y task-spooler
checkSuccess $? "Install task-spooler"

# Install Wiring Pi
pushd /tmp > /dev/null
checkSuccess $? "Change to temp dir"

sudo git clone git://git.drogon.net/wiringPi
checkSuccess $? "Get Wiring Pi Git Repo"

cd wiringPi
sudo ./build
checkSuccess $? "Build and Install Wiring Pi"

popd > /dev/null

# add www user to gpio group
adduser www-data gpio
checkSuccess $? "Add www user to gpio group"

# move GPIO Setup script to  init.d folder
cp gpio_access_rights /etc/init.d/gpio_access_rights
checkSuccess $? "Move GPIO setup to init.d"

pushd /etc/init.d > /dev/null
checkSuccess $? "Move to init.d"

chmod 755 gpio_access_rights
checkSuccess $? "Ensure the script has correct rights"

update-rc.d gpio_access_rights defaults
checkSuccess $? "Register startscript"

popd > /dev/null

# move scripts to www dir
cp ../www/access_remote.sh /var/www/access_remote.sh
checkSuccess $? "Move remote control access script to www dir"

cp ../www/access_remote_tsp.sh /var/www/access_remote_tsp.sh
checkSuccess $? "Move remote control access script for taskspooler to www dir"

cp ../www/velux.php /var/www/velux.php 
checkSuccess $? "Move php site to www dir"

pushd /var/www > /dev/null
checkSuccess $? "Change to www dir"

touch remote_log.txt
checkSuccess $? "Create log file in www folder"

chown www-data:pi remote_log.txt velux.php access_remote.sh
checkSuccess $? "Change file owner"

chmod g+rw +x remote_log.txt velux.php access_remote.sh
checkSuccess $? "Change file access right"

popd > /dev/null

echo "Setup completed!"
echo "Please reboot your Raspberry"
echo "After reboot check if everithing is working on http://<your raspberry ip>/velux.php"


exit 0

