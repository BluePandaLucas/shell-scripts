#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

echo "Please select your option:"
echo "[0] Install Wings"
echo "[1] Uninstall Wings"

read option

if option = "0" 
then
  echo "Selected option Install Wings"
elif option = "1" 
then
  echo "Stopping wings service."
  systemctl stop wings
  echo "Removing configuration files and service."
  rm -rf /var/lib/pterodactyl
  rm -rf /etc/pterodactyl
  rm /usr/local/bin/wings
  rm /etc/systemd/system/wings.service
  echo "Finished uninstalling Wings."
  echo "Thank you for using this script!"
else
  echo "Please retry and enter a valid option."
fi

done