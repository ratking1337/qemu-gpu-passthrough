#!/bin/sh

rebind() {
  echo "Unbinding"
  echo 0000:01:00.0 > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
  echo 0000:01:00.1 > /sys/bus/pci/devices/0000:01:00.1/driver/unbind
  echo 0000:01:00.2 > /sys/bus/pci/devices/0000:01:00.2/driver/unbind
  echo 0000:01:00.3 > /sys/bus/pci/devices/0000:01:00.3/driver/unbind

  echo "Rebinding"
   echo 8086 1e87 > /sys/bus/pci/drivers/vfio-pci/new_id
   echo 8086 108f > /sys/bus/pci/drivers/vfio-pci/new_id
   echo 8086 1ad8 > /sys/bus/pci/drivers/vfio-pci/new_id
   echo 8086 1ad9 > /sys/bus/pci/drivers/vfio-pci/new_id
}

rebind
