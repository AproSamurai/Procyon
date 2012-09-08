#!/bin/bash
#
# This script builds the CM kernel and copies it to the Epic MTD device tree.
# You must specify the path to your device tree.
#
#   export EPICMTDCM7PATH=/path/to/your/cm7repo >> ~/.bashrc
#   export EPICMTDCM9PATH=/path/to/your/cm9repo >> ~/.bashrc
#




TARGET_LOCALE="vzw"

#uncomment to add custom version string
export KBUILD_BUILD_VERSION="$CUSTOMVERSION"
DEFCONFIG_STRING=cyanogenmod_epicmtd_defconfig
INITRAMFS_SOURCE="/home/steven/Android/Procyon/usr/epicmtd_initramfs"
DEVICEPATH=device/samsung/epicmtd
#TOOLCHAINPATH=/toolchain/arm-eabi-4.4.3/bin
LOCALVERSION_STRING="-$CUSTOMVERSION"
CUSTOMVERSION="Procyon-X-"

#Test-Toolchain
TOOLCHAIN=/home/steven/Android/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin
TOOLCHAIN_PREFIX=arm-eabi-

#Primary-Toolchain
#TOOLCHAIN=/home/steven/Android/toolchain-4.6.3/bin
#TOOLCHAIN_PREFIX=arm-linux-androideabi-

#Secondary-Toolchain
#TOOLCHAIN=/home/steven/Android/arm-linux-androideabi-4.6/bin
#TOOLCHAIN_PREFIX=arm-linux-androideabi-


# Detect host OS
case "`uname`" in 
    Linux)
        PREBUILTARCH=linux-x86
        ;;
    Darwin)
        PREBUILTARCH=darwin-x86
        ;;
esac


# Display Environment

echo "$1 $2 $3"

case "$1" in
	Clean)
		echo "************************************************************"
		echo "* Clean Kernel                                             *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TCPATH/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
		popd
		echo " Clean is done... "
		exit
		;;
	mrproper)
		echo "************************************************************"
		echo "* mrproper Kernel                                          *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TCPATH/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
			make mrproper 2>&1 | tee make.mrproper.out
		popd
		echo " mrproper is done... "
		exit
		;;
	distclean)
		echo "************************************************************"
		echo "* distclean Kernel                                         *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TCPATH/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
			make distclean 2>&1 | tee make.distclean.out
		popd
		echo " distclean is done... "
		exit
		;;
	*)
		PROJECT_NAME=SPH-D700
		HW_BOARD_REV="03"
		;;
esac

if [ "$CPU_JOB_NUM" = "" ] ; then
	CPU_JOB_NUM=4
fi




KERNEL_BUILD_DIR=`pwd`/Kernel

export PRJROOT=$PWD
export PROJECT_NAME
export HW_BOARD_REV

export LD_LIBRARY_PATH=.:${TCPATH}/../lib

echo "************************************************************"
echo "* EXPORT VARIABLE                                          *"
echo "************************************************************"
echo "PRJROOT=$PRJROOT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "HW_BOARD_REV=$HW_BOARD_REV"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "************************************************************"

BUILD_MODULE()
{
	echo "************************************************************"
	echo "* BUILD_MODULE                                             *"
	echo "************************************************************"
	echo
	pushd Kernel
		make ARCH=arm modules
	popd
}

CLEAN_ZIMAGE()
{
	echo "************************************************************"
	echo "* Removing old zImage                                      *"
	echo "************************************************************"
	rm -f `pwd`/Kernel/arch/arm/boot/zImage
	echo "* zImage removed"
	echo "************************************************************"
	echo
}

BUILD_KERNEL()
{
	echo "************************************************************"
	echo "* BUILD_KERNEL                                             *"
	echo "************************************************************"
	echo
	
		export KDIR=`pwd`
# 		make clean mrproper
		make ARCH=arm $DEFCONFIG_STRING
#		make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.out
		make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX LOCALVERSION=$LOCALVERSION_STRING CONFIG_INITRAMFS_SOURCE=$INITRAMFS_SOURCE 2>&1 | tee make.out
		make V=1 -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.out

		cp arch/arm/boot/zImage /home/steven/Android/Procyon/Kexec-Build/
		cp arch/arm/boot/zImage /home/steven/Android/Procyon/Kexec-Build/kexec-cwm-test-zip
		cd /home/steven/Android/Procyon/Kexec-Build
		./make-kexec-cwm-test-zip.sh
		cd /home/steven/Android/Procyon/Kexec-Build/boot.img
		cp /home/steven/Android/Procyon/arch/arm/boot/zImage /home/steven/Android/Procyon/Kexec-Build/boot.img	
		./create_boot.img.sh cm		
		cp /home/steven/Android/Procyon/Kexec-Build/boot.img/boot.img /home/steven/Android/Procyon/Kexec-Build/update-zip		
		cd /home/steven/Android/Procyon/Kexec-Build/update-zip
		rm -f Procyon.zip		
		zip -r Procyon *
		cp /home/steven/Android/Procyon/Kexec-Build/update-zip/Procyon.zip /home/steven/Dropbox/Public/Procyon
		cp /home/steven/Android/Procyon/Kexec-Build/boot_zImage.zip /home/steven/Dropbox/Public/Procyon/
		cd /home/steven/Android/Procyon/Kexec-Build/
		rm -rf zImage
                rm -rf kexec-cwm-test-zip
		cd /home/steven/Dropbox/Public/Procyon/
		md5sum Procyon.zip
		md5sum boot_zImage.zip
}

# print title
PRINT_USAGE()
{
	echo "************************************************************"
	echo "* PLEASE TRY AGAIN                                         *"
	echo "************************************************************"
	echo
}

PRINT_TITLE()
{
	echo
	echo "************************************************************"
	echo "* MAKE PACKAGES                                            *"
	echo "************************************************************"
	echo "* 1. kernel : zImage"
	echo "* 2. modules"
	echo "************************************************************"
}

##############################################################
#                   MAIN FUNCTION                            #
##############################################################
if [ $# -gt 3 ]
then
	echo
	echo "************************************************************"
	echo "* Option Error                                             *"
	PRINT_USAGE
	exit 1
fi

START_TIME=`date +%s`
PRINT_TITLE
#BUILD_MODULE
CLEAN_ZIMAGE
BUILD_KERNEL
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo "Total compile time is $ELAPSED_TIME seconds "
