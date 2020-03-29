#!/bin/sh

USER=eevee

# Windows image and virtio drivers
WINIMG=/home/$USER/Downloads/Win10_1909_English_x64.iso
VIRTIMG=/home/$USER/Virtual/virtio-win-0.1.171.iso

# OVMF_CODE.fd renamed as bios.bin
BIOS=/home/$USER/Virtual/bios.bin

# Disks
MAIN_DISK=/dev/disk/by-id/ata-ADATA_SU800_2H2120055015
DISK0=/home/$USER/Virtual/win10.img

# Evdev
KBD0=/dev/input/by-id/usb-Razer_Razer_Huntsman_Tournament_Edition_00000000001A-event-kbd
KBD1=/dev/input/by-id/usb-Razer_Razer_Naga_Trinity_00000000001A-if01-event-kbd
MOUSE0=/dev/input/by-id/usb-Razer_Razer_Naga_Trinity_00000000001A-event-mouse

SCREAM=scream-ivshmem 

REBIND=/home/$USER/Virtual/drivers.sh
BARRIER=/home/$USER/Virtual/barrier.sh

for arg in "$@" ; do
    if [ "$arg" == "-r" ] ; then
        $REBIND
    fi
done

# Create shared memory file
touch /dev/shm/$SCREAM
chown $USER:kvm /dev/shm/$SCREAM
chmod 660 /dev/shm/$SCREAM

killall $SCREAM-pulse 2> /dev/null
echo Starting Scream
sudo su - $USER -c "scream-ivshmem-pulse /dev/shm/$SCREAM" &

if ! pgrep -x barriers > /dev/null ; then
  echo Starting Barrier
  $BARRIER $USER
fi

echo Staring VM

qemu-system-x86_64 --enable-kvm \
  -drive driver=raw,file=$DISK0 \
  -m 20000 \
  -net nic,model=virtio \
  -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
  -device virtio-keyboard-pci \
  -object input-linux,id=kbd,evdev=$KBD0,grab_all=on,repeat=on \
  -object input-linux,id=mouse,evdev=$MOUSE0 \
  -object input-linux,id=kbd2,evdev=$KBD1,grab_all=on,repeat=on \
  -net user,smb=$HOME \
  -cdrom ${VIRTIMG} \
  -drive file=${VIRTIMG},index=3,media=cdrom \
  -drive file=$MAIN_DISK,format=raw,media=disk \
  -rtc base=localtime,clock=host \
  -smp 12,sockets=1,cores=6,threads=2 \
  -bios $BIOS \
  -device ivshmem-plain,memdev=ivshmem_scream \
  -object memory-backend-file,id=ivshmem_scream,share=on,mem-path=/dev/shm/$SCREAM,size=2M \
  -device vfio-pci,host=01:00.0,multifunction=on,x-vga=on \
  -device vfio-pci,host=01:00.1 \
  -device vfio-pci,host=01:00.2 \
  -device vfio-pci,host=01:00.3 \
  -vga none \
  -nographic

