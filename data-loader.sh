#!/bin/bash 

#----------------------------------------------------------------------------------------------
# this component phraces the yaml from droidian
# this component is pulled from https://gist.github.com/pkuczynski/8665367


parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

#----------------------------------------------------------------------------------------------

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




download_device_files() { 
    (
    echo "10" 
    echo "# downloading adaption" 
    #download adaption
    wget $adaptation_url
    echo "20" 
    
    echo "# downloading vendor " 
    # download vendor 
    if [ -e vendor.img ]
    then
       # maybe check hash
       echo " "
    else 
       wget $vendor_url
    fi
    echo "40" 
    
    echo "# downloading halium boot"
    #download halium boot
    rm -f boot.img
    wget  $boot_url
    echo "60"
    
    echo "#  download recovery " 
    # download recovery 
    if [ -e recovery.img ]
    then
       # maybe check hash
       echo " "
    else 
       wget $recovery_url
    fi 
    echo "80"
    
    echo "# downloading firmware" 
     # download firmware  
    if [ -e firmware.zip ]
    then
       # maybe check hash
       echo " "
    else 
       wget $firmware_url
    fi 
    echo "100"
    
    ) |
    zenity --progress \
           --window-icon=logo.png \
           --width 500 \
           --height 300 \
           --title="Downloading Device Packages" \
           --text="Downloading..." \
           --percentage=0

    if [ "$?" = -1 ] ; then
            zenity --error \
              --text="Download Failed."
    fi
}
#----------------------------------------------------------

process_files() { 
    #setting file names for flashing 

    #unzip recovery if using orengefox
    unzip OrangeFox*.zip

    #rename if using  twrp 
    cp twrp*.img recovery.img


    #unzip vendor 
    unzip vendor.zip

    #rename vendor if vendor has big filename 
    cp vendor*.img vendor.img

    #rename adaptation 
    cp *adaptation*.zip adaptation.zip 

    #rename firmware
    cp fw_*.zip firmware.zip

    #if lineage os itself is given
    cp lineage*.zip lineage.zip 
}

#----------------------------------------------------------
