#!/bin/sh

SERVERNAME=$(hostname)
CONFIG=/home/$1/.config/barrier/barrier.conf
sudo su - $1 -c "barriers --no-tray \
         --debug INFO \
         --name $SERVERNAME \
         --enable-crypto \
         -c $CONFIG \
         --address :24800"
