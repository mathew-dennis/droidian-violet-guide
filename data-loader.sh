#!/bin/bash 

get_yaml() {
    rm -Rf yaml ; mkdir yaml; cd yaml
    wget https://github.com/thomashastings/droidian-devices/archive/refs/heads/main.zip 
    unzip main.zip
    cd ..

    for f in yaml/droidian-devices-main/devices/*.yml; do
      fnew=`echo $f | sed 's/.yml//'`
      mv $f $fnew
    done
    rm -Rf .yaml ; mkdir .yaml; 
    mv yaml/droidian-devices-main/devices/* .yaml/
    rm -Rf yaml
}


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



download_device_files() { 
    (
    echo "10" 
    echo "# downloading adaption" 
    #download adaption
    wget $url_adaptation_link
    echo "20" 
    
    echo "# downloading vendor " 
    # download vendor 
    if [ -e vendor.img ]
    then
       # maybe check hash
       echo " "
    else 
       wget $url_vendor_zip_link
    fi
    echo "40" 
    
    echo "# downloading halium boot"
    #download halium boot
    rm -f boot.img
    wget  $url_boot_link
    echo "60"
    
    echo "#  download recovery " 
    # download recovery 
    if [ -e recovery.img ]
    then
       # maybe check hash
       echo " "
    else 
       wget $url_recovery_link
    fi 
    echo "80"
    
    echo "# downloading firmware" 
     # download firmware  
    if [ -e firmware.zip ]
    then
       # maybe check hash
       echo " "
    else 
       wget $url_android_link
    fi 
    echo "#download complete please press 'ok' to continue"
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
