#!/bin/sh

if cat /etc/modprobe.d/vfio.conf | grep \# > /dev/null ; then
  echo $(cat /etc/modprobe.d/vfio.conf | sed -e "s/\#\s//g") > /etc/modprobe.d/vfio.conf
else 
  echo "# "$(cat /etc/modprobe.d/vfio.conf) > /etc/modprobe.d/vfio.conf
fi

genkernel --install initramfs
