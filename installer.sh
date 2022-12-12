#!/bin/bash 
# script by mathew dennis  https://github.com/mathew-dennis

#include device data handler functions
. data-loader.sh

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
for name in fastboot adb zenity axel
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
                True  xiaomi_violet "Redmi note 7 pro" \
                False xiaomi_kenzo "Redmi note 3"
                )
                
 
echo "you have chosen " $device
# echo "would you like to dual boot Droidian along with ubuntu-touch / android (yes or no )"
# echo " "
# echo "if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img' "
# echo "if your device is a/b (a relatviely newer device) this will write droidian to one of the partitions"
# echo " "
# echo "this is experimental please input 'no' if you dont want to take the risk "


#--------------------------------------------------------------------------------------------------------------
#the following zenity code is pulled from this link
#https://askubuntu.com/questions/478186/help-creating-a-messagebox-notification-with-yes-no-options-before-an-applicatio
if zenity --question \
          --window-icon=logo.png \
          --width 500 \
          --height 300 \
          --text="Would You like to wipe data . this cannot be undone "
then
    #zenity --info --text="You pressed \"Yes\"!"
    wipe_data=yes
else
   # zenity --info --text="You pressed \"No\"!"
    wipe_data=no
fi

echo "Your choice for wipe data ? is" $wipe_data

# if zenity --question \
#           --window-icon=logo.png \
#           --width 500 \
#           --height 300 \
#           --text="would you like to dual boot Droidian along with ubuntu-touch / android (yes or no ) \n \n  if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img'"
# then
    #zenity --info --text="You pressed \"Yes\"!"
#     dual_boot=yes
# else
   # zenity --info --text="You pressed \"No\"!"
#     dual_boot=no
# fi
# echo "Your choice for dual boot is" $dual_boot

#depricated as we use zenity
#read dual_boot
#------------------------------------------------------------------------------------------------------------------

#download device yml
eval $(get_yaml2)

#parse yaml of the selected device
eval $(parse_yaml .yaml/$device.yml "url_")

#setup device enviornment 
#eval $(setup_dev_env)
#echo "device use lineage = " $device_use_lineage
 echo "vendor is recovery flashable = " $url_vendor_zip_is_recovery_flashable
 
# downloading rootfs
api=$url_api_version

echo "device api version is = " $api

if [ $api = API28 ]
 then 
  url_droidian_rootfs=https://images.droidian.org/rootfs-api28gsi-all/nightly/arm64/generic/rootfs.zip
  echo " api level is 28, download url= " $url_droidian_rootfs 
  
elif [ $api = API29 ]
 then
   url_droidian_rootfs=https://images.droidian.org/rootfs-api29gsi-all/nightly/arm64/generic/rootfs.zip
  echo " api level is 29, download url= " $url_droidian_rootfs 
  
else 
  echo "unsupported api level" && exit 0
fi
  
if [ -e droidian_rootfs_$api.zip ]
 then
   if zenity --question \
             --window-icon=logo.png \
             --width 500 \
             --height 300 \
             --text=" droidian rootfs exists ,would you like to re-download " 
   # zenity will return true or false based on user responce ...
   then
      echo "re-downloading rootfs"
      rm -f rootfs.zip droidian_rootfs_$api.zip
      axel  -n 16 $url_droidian_rootfs
      # if [$url_droidian_release] then wget $url_droidian_release fi
      
      mv rootfs.zip droidian_rootfs_$api.zip
   else
      echo "skipping re-download.. "
   fi
    
else
   rm -f rootfs.zip
   echo "downloading rootfs"
   axel -n 16 $url_droidian_rootfs
   #if [$url_droidian_release] then wget $url_droidian_release fi
   
   mv rootfs.zip droidian_rootfs_$api.zip
fi


#print the download links 
echo -e vendor: "$url_vendor_zip_link\nadaptation: $url_adaptation_link \n"
echo -e boot: "$url_boot_link \nrecovery: $url_recovery_link \nfirmware $url_android_link"


# moving to a device specific directory. as, the user might like to install droidian on multiple devices
mkdir $device
cd $device

eval $(download_device_files)

eval $(process_files)

# actuall install 

echo "installing droidian.."
echo "please boot your device to fastboot mode by pressing vol- and power button at the same time"

# step 0 ----------------------------------------------------------------------------------------------
# handle device wipe request

if [ $wipe_data = yes ]
then
 echo "wipe data"
 fastboot erase userdata
else 
 echo "do not wipe data"
 #do nothing
fi
#------------------------------------------------------------------------------------------------
#fix me ;; we need to verify fastboot device is the correct one.





#step 1-------------------------------------------------------------------------------------------
#flash recovery and boot to Device


#condition for devices that can't handle fastboot boot command
if [ $url_recovery_must_flash = true ]
then
   #This is not a mistake, Its by design.
   fastboot flash boot recovery.img 
   fastboot reboot
else
   fastboot boot recovery.img
fi


#jump back to main folder to install droidian
cd .. 

#--- verify device is the correct one---------------------------------------------------------

i=0
while [ true ]
do
    hi=$(adb shell getprop ro.product.device)
    hi2=$url_codename
    if [ $hi  = $hi2  ] 
    then
           echo "$hi = $hi2 ,device found " && break

    else 
           echo "Device $hi2 not connected. Attempt $i "    
    fi
    sleep 1 && i=`expr $i + 1`

    if [ i = 600 ]
     then 
        echo "waited too long no device detected " && exit 0
    fi
done

# waiting for device to get ready
sleep 10


#step 2------------------------------------------------------------------------------------------------
#push files and flash them
# reference 
#https://forum.xda-developers.com/t/flash-zip-files-from-adb-terminal-and-other-commands.1353234/

adb push droidian_rootfs_$api.zip /data/droidian_rootfs_$api.zip
adb push reboot_packet.zip        /data/reboot_packet.zip
# going to device directory to push device specific files 
cd $device

adb push adaptation.zip           /data/adaptation.zip
adb push firmware.zip             /data/firmware.zip
adb push lineage.zip              /data/lineage.zip 


adb shell "echo 'boot-recovery ' > /cache/recovery/command"
adb shell "echo '--update_package=/data/firmware.zip' >> /cache/recovery/command"


#if [ true ] 
#then 
#  adb shell "echo '--update_package=/data/lineage.zip' >> /cache/recovery/command"
#fi

adb shell "echo '--update_package=/data/droidian_rootfs_$api.zip' >> /cache/recovery/command"
adb shell "echo '--update_package=/data/adaptation.zip' >> /cache/recovery/command"
adb shell "echo '--update_package=/data/reboot_packet.zip' >> /cache/recovery/command"

adb reboot recovery

#The reboot_packet will make the device reboot to bootloader 

if [ -e vendor.img ]
then 
   #flash it 
#fix me: add dual boot support for normal and a/b device

dual_boot=no

 if [ $dual_boot = yes ]
 then
    adb push vendor.img /data/vendor.img
 fi

else 
 fastboot flash vendor  vendor.img
fi
 
fastboot flash boot boot.img && fastboot flash recovery recovery.img  && fastboot reboot
  
eval $(zenity_worker info "Flashing done!" "Installer has sucessfully flashed Droidian on $device. Have fun ;) " )

echo "all done " && exit 0
