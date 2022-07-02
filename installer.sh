#!/bin/bash 
# script by mathew dennis  https://github.com/mathew-dennis

clear
echo " "
echo "Welcome to Droidian installer"
echo " "

#set device variable 
#export device=violet

#-----------------------------------------------------------------------------------------------------------------------

# The following component checks for dependencies.
#This component is pulled from https://stackoverflow.com/questions/33297857/how-to-check-dependency-in-bash-script

echo -n "Checking dependencies... "
for name in fastboot adb zenity
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name needs to be installed. Use 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "OK" || { echo -en "\nInstall the above and rerun this script\n";exit 1; }

#------------------------------------------------------------------------------------------------------------------------

#Gui elments using zenity......
zenity --info \
       --window-icon=logo.png \
       --title "Installer" \
       --width 500 \
       --height 300 \
       --text "Welcome to Droidian installer. please click 'ok' to continue"
       --ok-label="next"
       
device=$(zenity --list \
                --window-icon=logo.png \
                --width 500 \
                --height 300 \
                --title="Please select your device" \
                --radiolist --column="selection"  --column="Code Name" --column="Name" \
                True  violet "Redmi note 7 pro" \
                False kenzo "Redmi note 3"
                )
       
echo "you have chosen " $device
echo "would you like to dual boot Droidian along with ubuntu-touch / android (yes or no )"
echo " "
echo "if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img' "
echo "if your device is a/b (a relatviely newer device) this will write droidian to one of the partitions"
echo " "
echo "this is experimental please input 'no' if you dont want to take the risk "


#--------------------------------------------------------------------------------------------------------------
#the following zenity code is pulled from this link
#https://askubuntu.com/questions/478186/help-creating-a-messagebox-notification-with-yes-no-options-before-an-applicatio

if zenity --question \
          --window-icon=logo.png \
          --width 500 \
          --height 300 \
          --text="would you like to dual boot Droidian along with ubuntu-touch / android (yes or no ) \n \n  if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img'"
then
    #zenity --info --text="You pressed \"Yes\"!"
    dual_boot=yes
else
   # zenity --info --text="You pressed \"No\"!"
    dual_boot=no
fi
echo "Your choice for dual boot is" $dual_boot

#depricated as we use zenity
#read dual_boot
#------------------------------------------------------------------------------------------------------------------

# downloading rootfs

if [ -e droidian_rootfs.zip ]
then
   if zenity --question \
             --window-icon=logo.png \
             --width 500 \
             --height 300 \
             --text=" droidian rootfs exists ,would you like to re-download " 
   # zenity will return true or false based on user responce ...
   then
      echo "re-downloading rootfs"
      rm -f rootfs.zip droidian_rootfs.zip
      wget https://images.droidian.org/rootfs-api28gsi-all/nightly/arm64/generic/rootfs.zip
      mv rootfs.zip droidian_rootfs.zip
   else
      echo "skipping re-download.. "
   fi
    
else
   rm -f rootfs.zip
   echo "downloading rootfs"
   wget https://images.droidian.org/rootfs-api28gsi-all/nightly/arm64/generic/rootfs.zip
   mv rootfs.zip droidian_rootfs.zip
fi


#load device data handler functions
. data-loader.sh

#eval $(parse_yaml zconfig.yml "url_")

# moving to a device specific directory. as, the user might like to install droidian on multiple devices
mkdir $device
cd $device

eval $(download_device_files)

eval $(process_files)

# actuall install 

echo "installing droidian.."
echo"please boot your device to fastboot mode by pressing vol- and power button at the same time"

#condition for devices that cant handle fastboot boot command
if [ $device = violet ]
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

if [ -e vendor.img ]
then 
   #flash it 
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
    fastboot flash boot boot.img && fastboot flash recovery recovery.img  && fastboot reboot
    
echo "all done "
    
