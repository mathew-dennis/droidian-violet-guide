echo " "
echo "Welcome to Droidian installer for Redmi Note 7 Pro"
echo " "

#set device varible 
device=violet

#load device data
./data-loader.sh

echo "would you like to dual boot Droidian along with ubuntu-touch / android (yes or no )"
echo " "
echo "if your device is non- a/b (old but has treble) this will flash droidian's boot image to your recovery partition .so booting into recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img' "
echo "if your device is a/b (a relatviely newer device) this will write droidian to one of the partitions"
echo " "
echo "this is experimental enter 'no' if you dont want to take the risk "

read dual-boot


# downloading rootfs

if [ -e droidian-rootfs-api28gsi-arm64*.zip ]
then
    echo " "
    echo "you have downloaded droidian for a previous install."
    echo "would you like to re-download(you say 'no' if its relatively new )  "
    echo "yes or no"
    echo " "
    read re-download
    
    if [$re-download == yes ]
    then
        rm -f droidian-rootfs-api28gsi-arm64*.zip
        wget https://github.com/droidian-images/rootfs-api28gsi-all/releases/download/nightly/droidian-rootfs-api28gsi-arm64_20220514.zip
    else
        echo "complete "
    fi
    
else
    echo "downloading"
    wget https://github.com/droidian-images/rootfs-api28gsi-all/releases/download/nightly/droidian-rootfs-api28gsi-arm64_20220514.zip
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

#download halium boot
wget  $boot_url


# download recovery 
if [ -e recovery.img ]
then
    # maybe check hash
else 
   wget recovery_url
fi 


# download firmware  
if [ -e firmware.zip ]
then
    # maybe check hash
else 
   wget firmware_url
fi 
#----------------------------------------------------------
#device specific stuff (violet)

#fix me : we need to move this part as well to data-loader script 

#unzip recovery 
uzip OrangeFox-violet-stable@R11.1_1.zip

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

adb sideload droidian-rootfs-api28gsi-arm64*.zip


adb sideload droidian-recovery-flashing-adaptation-violet.zip

adb reboot fastboot

# going to device directory
cd $device

if [$dual-boot == yes ]
then
    fastboot flash recovery boot.img && fastboot reboot
else 
    fastboot flash boot boot.img  && fastboot reboot
    
echo "all done "
    
