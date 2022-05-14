#!/bin/bash 
# script by mathew dennis  https://github.com/mathew-dennis

clear
echo " "
echo "Welcome to Droidian installer"
echo " "

#set device variable 
export device=violet

#load device data
./data-loader.sh

echo "please make sure that the following dependencies are installed:  adb fastboot "

echo "would you like to dual boot Droidian along with ubuntu-touch / android (yes or no )"
echo " "
echo "if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img' "
echo "if your device is a/b (a relatviely newer device) this will write droidian to one of the partitions"
echo " "
echo "this is experimental please input 'no' if you dont want to take the risk "

read dual_boot


# downloading rootfs

if [ -e droidian_rootfs.zip ]
then
   echo " "
   echo "you have downloaded droidian for a previous install."
   echo "would you like to re-download(please say 'no' if its relatively new )  "
   echo "yes or no"
   echo " "
   read re_download
    
   if [ $re_download = yes ]
   then
      rm -f rootfs.zip droidian_rootfs.zip
      wget https://images.droidian.org/rootfs-api28gsi-all/nightly/arm64/generic/rootfs.zip
      mv rootfs.zip droidian_rootfs.zip
   else
      echo "complete "
   fi
    
else
   rm -f rootfs.zip
   echo "downloading"
   wget https://images.droidian.org/rootfs-api28gsi-all/nightly/arm64/generic/rootfs.zip
   mv rootfs.zip droidian_rootfs.zip
fi

#download adaption
wget $adaptation_url


# moving to a device specific directory. as, the user might like to install droidian on multiple devices
mkdir $device
cd $device

# download vendor 
if [ -e vendor.img ]
then
   # maybe check hash
else 
   wget $vendor_url
fi

#download halium boot
rm -f boot.img
wget  $boot_url

# download recovery 
if [ -e recovery.img ]
then
   # maybe check hash
else 
   wget $recovery_url
fi 


# download firmware  
if [ -e firmware.zip ]
then
   # maybe check hash
else 
   wget $firmware_url
fi 
#----------------------------------------------------------
#device specific stuff (violet)

#fix me : we need to move this part as well to data-loader script 

#unzip recovery 
unzip OrangeFox-violet-stable@R11.1_1.zip

#unzip vendor 
unzip vendor.zip

#rename firmware
cp fw_violet_miui_VIOLETINGlobal_V11.0.5.0.*.zip firmware.zip

#----------------------------------------------------------



echo "installing droidian.."
echo"please boot your device to fastboot mode by pressing vol- and power button at the same time"

if [ $device==violet ]
then
   fastboot flash recovery recovery.img && fastboot reboot
else
   fastboot boot recovery.img
fi

#jump back to main folder to install droidian
cd .. 


#fix me ..we need a method to check if adb device is connected and the device is $device and continue

echo "the device will now reboot to recovery.."
sleep 3
read -p "please press 'enter' when device is in recovery"

adb sideload droidian-rootfs.zip


adb sideload droidian-recovery-flashing-adaptation-violet.zip

adb reboot bootloader

# going to device directory
cd $device

#fix me: add dual boot support for a/b device

if [ $dual_boot = yes ]
then
   if [ -e vendor.img ]
   then
      adb push vendor.img /data/vendor.img
   fi
   fastboot flash recovery boot.img && fastboot reboot
else 
    if [ -e vendor.img ]
    then
       fastboot flash vendor  vendor.img
    fi
    fastboot flash boot boot.img  && fastboot reboot
    
echo "all done "
    
