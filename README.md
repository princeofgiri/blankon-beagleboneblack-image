This prepare minimal BlankOn for BeagleBone Black. It`s already configured for HDMI display.

### Requirements
* devrootfs that contain BlankOn rootfs
* git, kpartx, qemu, debootstrap, qemu-user-static

### Steps
* clone this repository	
```
git clone https://github.com/princeofgiri/blankon-beagleboneblack-image && cd blankon-beagleboneblack-image
```
* creating rootfs
```
sudo qemu-debootstrap --arch armhf tambora devrootfs http://arsip.blankonlinux.or.id/blankon /usr/share/debootstrap/scripts/tambora
```
* you can add user and change password via chroot
* run
```
./build.sh
```
* write to your sdcard
```
sudo dd if=beagleboneblack-blankon.img of=/dev/[yoursdcarddevice] bs=4M;sync
```
* boot to your beaglebone black
