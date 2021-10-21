#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

echo Removing apache2

systemctl stop apache2
systemctl disable apache2
apt remove apache2
apt autoremove

echo Installing NGINX

apt clean all && sudo apt update && sudo apt dist-upgrade
apt install NGINX

echo Installing and setting up UFW

apt-get install ufw 
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow ftp
ufw allow www
ufw allow "Nginx Full"

echo Enabled UFW 
ufw enable 

