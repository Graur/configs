#!/bin/bash

access=$(sudo -nv 2>&1)
if [ $? -eq 0 ]; then
  echo "Access granded"
elif echo $access | grep -q '^sudo:'; then
  echo "Access granded"
else
  echo "You don't have sudo permissions"
  exit -1
fi

status=$(getenforce)
cfg=$(cat /etc/selinux/config | grep "^SELINUX=" | sed 's/^SELINUX=//g')

echo "SELinux status is: $status"
echo "SELinux status in config is: $cfg"

if [[ "$status" == "Enforcing" ]]; then
  echo "Do you want to disable SELinux? (y/n)"
else
  echo "Do you want to enable SELinux? (y/n)"
fi

read answer

if [[ ( "$answer" == "y" ) && ( "$status" == "Enforcing" ) ]]; then
  sudo setenforce 0
  echo "SELinux disabled"
elif [[ ( "$answer" == "y" ) && ( "$status" == "Disabled" ) || ( "$status" == "Permissive" ) ]]; then
  sudo setenforce 1
  echo "SELinux enabled"
else
  exit 0
fi

if [[ "$cfg" == "enforcing" ]]; then
  echo "Do you want to disable SELinux in config? (y/n)"
else
  echo "Do you want to enable SELinux in config? (y/n)"
fi

read cfganswer

if [[ ( "$cfganswer" == "y" ) && ( "$cfg" == "enforcing" ) ]]; then
  sudo sed 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config | sudo tee /etc/selinux/config > /dev/null
  echo "SELinux in config is disabled"
elif [[ ( "$cfganswer" == "y" ) && ( "$cfg" == "disabled" ) ]]; then
  sudo sed 's/^SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config | sudo tee /etc/selinux/config > /dev/null
  echo "SELinux in config is enabled"
elif [[ ( "$cfganswer" == "y" ) && ( "$cfg" == "permissive" ) ]]; then
  sudo sed 's/^SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config | sudo tee /etc/selinux/config > /dev/null
  echo "SELinux in config in enabled"
else
  exit 0
fi
