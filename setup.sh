#!/bin/bash

set -e

# Basic checks:
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi


# Variables
GITHUB_SOURCE="main"

SWITCH_TO_NGINX=true
CONFIGURE_UFW=true


# Visual functions
print_error() {
    CLOLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

# OS detection
detect_distro() {
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

# OS specific stuff
apt_update() {
  apt update -q -y && apt upgrade -y
}

# Installion:
remove_apache2() {
    echo "Removing apache2."
    systemctl stop apache2
    systemctl disable apache2
    apt remove apache2
    apt autoremove
    echo "Finished removing apache2."
}

install_ufw() {
    echo "Installing UFW."
    apt-get install ufw
    echo "Finished installing UFW."

}

install_nginx() {
    echo "Installing NGINX."
    apt clean all
    apt_update
    apt install nginx
    echo "Finished installing NGINX."
}

configure_ufw() {
    echo "Configuring UFW."
    ufw deny incoming
    ufw allow outgoing
    ufw allow ssh
    ufw allow ftp
    ufw allow www
    ufw allow "Nginx Full"
    echo "Finished configuration for UFW."
    print_brake 50
    echo "Enabling UFW."
    ufw enable
    echo "Enabled UFW, printing status:"
    ufw status
}

# Main
main() {
    detect_distro

    print_brake 70
    echo "* Configuration script by BluePandaLucas, don't use unless you need to."
    echo "* I'm a beginner to shell and linux in general."
    echo "*"
    echo "* Some code here is from Vilhem Prytz's installer script for Pterodactyl."
    echo "* Running $OS version $OS_VER"
    print_brake 70

    echo -e -n "Are you sure you want to continue?"
    read -r 
    apt_update
    remove_apache2
    install_ufw
    install_nginx
    configure_ufw
}   

echo "NOT FINISHED CANCEL NOW"
read -r