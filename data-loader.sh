#!/bin/bash 

if [ $device = violet ]
then
    adaptation_url=https://github.com/mathew-dennis/droidian-recovery-flashing-adaptation-violet/releases/download/v1.1/droidian-recovery-flashing-adaptation-violet.zip
    
    vendor_url=https://github.com/ubuntu-touch-violet/ubuntu-touch-violet/releases/download/20210510/vendor.zip
    
    boot_url=https://gitlab.com/mathew-dennis/xiaomi-violet/-/jobs/2428049402/artifacts/raw/out/boot.img
    
    recovery_url=https://us-dl.orangefox.download/61c249bef2082f874065b8a5
    
    firmware_url=https://mirrors.gigenet.com/OSDN//storage/g/x/xi/xiaomifirmwareupdater/Stable/V11/violet/fw_violet_miui_VIOLETINGlobal_V11.0.5.0.PFHINXM_04632f47d3_9.0.zip
    
else
    echo "please add urls for your " $device
    read -p "please re-run the installer after that..."   
fi
