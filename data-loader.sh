#!/bin/bash 

get_yaml2(){

device_yaml=https://raw.githubusercontent.com/droidian-devices/devices.droidian.org/master/data/supported-devices/devices/$device.yml
echo "device_yaml= "  $device_yaml
rm $device_yaml .yaml/$device.yml
mkdir .yaml
wget $device_yaml
mv $device.yml .yaml/$device.yml

}

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

setup_dev_env() {
 if [  $url_android_filename != null ]
 then
  device_use_lineage=true
 else 
  device_use_lineage=false
 fi
 
 if  [  $url_vendor_image_filename != null ]
 then
  device_use_direct_vendor_image=true
 else 
  device_use_direct_vendor_image=false
 fi
}
#----------------------------------------------------------------------------------------------
download_device_files() { 
    (
    echo "10" 
    echo "# downloading adaption" 
    #download adaption
    wget $url_adaptation_direct_download_link
    echo "20" 
    
    echo "# downloading vendor " 
    # download vendor 
    if [ -e vendor.img ] || [ -e vendor.zip ]
    then
       # maybe check hash
       echo " "
    else 
       #https://askubuntu.com/questions/214018/how-to-make-wget-faster-or-multithreading
       echo "initializing vendor download"
       axel -n 4 $url_vendor_zip_direct_download_link
       axel -n 4 $url_vendor_image_direct_download_link
    fi
    echo "40" 
    
    echo "# downloading halium boot"
    #download halium boot
    rm -f boot.img
    wget  $url_boot_direct_download_link
    echo "60"
    
    echo "#  download recovery " 
    # download recovery 
    if [ -e recovery.img ]
    then
       # maybe check hash
       echo " "
    else 
       wget $url_recovery_direct_download_link
    fi 
    echo "80"
    
    echo "# downloading firmware" 
     # download firmware  
    if [ -e firmware.zip ]
    then
       # maybe check hash
       echo " "
    else 
       wget $url_firmware_direct_download_link
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
           --auto-close

    if [ "$?" = -1 ] ; then
            zenity --error \
              --text="Download Failed."
    fi
}
#----------------------------------------------------------

process_files() { 
    #setting file names for flashing 

    #unzip recovery if using orangefox
    
    mkdir temp
    unzip -d temp OrangeFox*.zip
    mv /temp/recovery.img recovery.img
    rm -Rf temp

    #rename if using  TWRP 
    cp twrp*.img recovery.img


    #handle and rename vendor
     
    cp $url_vendor_zip_filename vendor.zip
    cp $url_vendor_image_filename vendor.img
    
    if [ $url_vendor_zip_is_recovery_flashable = true ] || [ -e vendor.img ]
     then 
      echo " "
    else 
      unzip vendor.zip
      mv vendor*.img vendor.img
    fi
    
    #rename adaptation 
    cp $url_adaptation_filename adaptation.zip 

    #rename firmware
    cp $url_firmware_filename firmware.zip

    #if lineage OS itself is given
    cp lineage*.zip lineage.zip 
}

#----------------------------------------------------------
#usage eval ($zenity_worker type "title" "text" )
# accepted types >> info warning error
zenity_worker() {
 zenity --$1 \
       --window-icon=logo.png \
       --title "$2" \
       --width 500 \
       --height 300 \
       --text "$3"
  }
#---------------------------------------------------------
