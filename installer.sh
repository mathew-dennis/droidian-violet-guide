echo " "
echo "Welcome to Droidian installer for Redmi Note 7 Pro"
echo " "

#set device varible 
device=violet

echo "would you like to dual boot Droidian along with ubuntu-touch / android (yes or no )"
echo " "
echo "if your device is non- a/b (old but has treble) this will flash droidians boot image to your recovey .so booting in to recovery will be booting droidian .to get recovery you will have to reflash recovery using 'fastboot flash recovery recovery.img "
echo "if your device is a/b (a relatviely newer device) this will write droidian to one of the partisions"
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
wget https://github.com/mathew-dennis/droidian-recovery-flashing-adaptation-violet/releases/download/v1.1/droidian-recovery-flashing-adaptation-violet.zip


# moving to a device specific folder as the user might like to install droidian on multiple devices
mkdir $device
cd $device

# download vendor 
if [ -e vendor.img ]
then
    # maybe check hash
else 
   wget https://github.com/ubuntu-touch-violet/ubuntu-touch-violet/releases/download/20210510/vendor.zip
fi 

#download halium boot
wget  https://gitlab.com/mathew-dennis/xiaomi-violet/-/jobs/2428049402/artifacts/file/out/boot.img


# download recovery 
if [ -e recovery.img ]
then
    # maybe check hash
else 
   wget https://us-dl.orangefox.download/61c249bef2082f874065b8a5
   uzip OrangeFox-violet-stable@R11.1_1.zip
fi 
#----------------------------------------------------------
#device specific stuff

#unzip recovery 
uzip OrangeFox-violet-stable@R11.1_1.zip

#unzip vendor 
unzip vendor 

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

echo "the device will reboot to recovery.."
wait 1
read -p "please press enter when device is in recovery"

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
    
