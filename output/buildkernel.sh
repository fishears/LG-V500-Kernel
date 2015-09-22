#!/bin/bash
BASE_FISH_VER="Fishearskernel_v500_"
VER="1.0.2"
FISH_VER=$BASE_FISH_VER$VER

export LOCALVERSION="-"`echo $FISH_VER`
export CROSS_COMPILE=./arm-eabi-4.8/bin/arm-eabi-
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=fishears
export KBUILD_BUILD_HOST="kernel"

OUTPUT_DIR=./output
MODULES_DIR=./output/modules
KERNEL_DIR=~/developer/android/kernel

echo "LOCALVERSION="$LOCALVERSION
echo "CROSS_COMPILE="$CROSS_COMPILE
echo "ARCH="$ARCH
echo "MODULES_DIR="$MODULES_DIR
echo "KERNEL_DIR="$KERNEL_DIR
echo "OUTPUT_DIR="$OUTPUT_DIR

cd $KERNEL_DIR
make awifi-perf_defconfig
make -j4

cd $OUTPUT_DIR
rm zImage zipfile/boot.img bootin.img
cp $KERNEL_DIR'/arch/arm/boot/zImage' .
mkbootimg --base 0 --pagesize 2048 --kernel_offset 0x80208000 --ramdisk_offset 0x82200000 --second_offset 0x81100000 --tags_offset 0x80200100 --cmdline 'console=ttyHSL0,115200,n8 user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.hardware=awifi vmalloc=600M androidboot.bootdevice=msm_sdcc.1  androidboot.selinux=permissive' --kernel zImage --ramdisk ramdisk.cpio.gz -o bootin.img
./bump.py bootin.img zipfile/boot.img
find $KERNEL_DIR -name "*.ko" -exec cp {} zipfile/system/lib/modules/ \;
cp updater-scriptCUSTOM zipfile/META-INF/com/google/android/updater-script
cd zipfile
zip -r9 ../$FISH_VER'.zip' *
