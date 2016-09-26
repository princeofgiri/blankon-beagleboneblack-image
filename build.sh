#!/bin/bash

. settings

MIN_SIZE=1000
if [ $SIZE -lt $MIN_SIZE ];then
  echo "SIZE in settings is too small for this build"
  echo "It should be more than $MIN_SIZE"
  exit
fi


if [ ! -f boot/zImage ];then
  echo "No kernel found, please put zImage file here"
  exit
fi

rm -rf build/
mkdir build/
cp -rfv boot build/

OUTPUT=beagleboneblack-blankon.img

if [ ! -d devrootfs ];then
  echo "devrootfs/ directory is not found"
  echo "You should prepare a debootstrap in that directory"
  echo "e.g. $ sudo debootstrap tambora devrootfs"
  exit
fi

dd if=/dev/zero of=$OUTPUT  bs=1M count=$SIZE
echo -e "o\nn\np\n1\n\n+100M\nt\ne\na\nn\np\n\n\n\nw\n" | /sbin/fdisk $OUTPUT 
sudo modprobe loop
sudo kpartx -a $OUTPUT

# First partition
DEV=`sudo kpartx -l $OUTPUT | head -1 | cut -f1 -d' '`
if [ -z $DEV ];then
  echo "Partitions in $OUTPUT can't be read"
  exit
fi
sleep 1
sudo mkfs.vfat /dev/mapper/$DEV
mkdir -p mnt
sudo mount /dev/mapper/$DEV mnt

sudo cp -rfv build/boot/* mnt 
sudo umount mnt

# Second partition
DEV=`sudo kpartx -l $OUTPUT | tail -1 | cut -f1 -d' '`
if [ -z $DEV ];then
  echo "Partitions in $OUTPUT can't be read"
  exit
fi
sleep 1
sudo mkfs.ext2 /dev/mapper/$DEV
sudo tune2fs -i 0 -c 0 /dev/mapper/$DEV  -L BlankOn -O ^has_journal

mkdir -p mnt
sudo mount /dev/mapper/$DEV mnt
echo "Creating /etc/fstab"
echo "/dev/mmcblk0p2  / ext2 defaults 1 2" > devrootfs/etc/fstab
sudo cp -a devrootfs/* mnt 
sudo umount mnt

sudo kpartx -d $OUTPUT

sudo losetup -d /dev/${DEV:0:5}
