# Droidian for the Xiaomi Redmi note 7 pro
A collection of tips on how to install and use Droidian on the Xiaomi Redmi note 7 pro  (violet)

### Requirements
- A computer with fastboot and adb access to the phone
- Unlocked bootloader
- Backup all your data, as **your phone will be WIPED**
- It is also recommended to take a note of your `Acces Point Name` in Android `Settings` before starting the procedure (you will need it for setting up mobile data)

## Installation
### 0. Download files
- [Droidian `rootfs` and `devtools`](https://github.com/droidian-images/rootfs-api28gsi-all/releases) for `arm64` (nightly releases include devtools)
- [Adaptation](https://github.com/thomashastings/droidian-recovery-adaptation-jasmine/releases)
- [Android 9 Pie Firmware](https://xiaomifirmwareupdater.com/firmware/violet/weekly/9.9.3/)
- [Android 9 vendor](https://github.com/ubuntu-touch-violet/ubuntu-touch-violet/releases/tag/20210510)
- [Halium-boot](https://gitlab.com/mathew-dennis/xiaomi-violet/-/jobs/2428049402/artifacts/file/out/boot.img)
- Latest [Orenge fox recovery ](https://orangefox.download/device/violet)

### 1. Flash  Boot,Recovery and Vendor 
- Boot to fastboot mode by pressing the `Vol-` and `Power` buttons until the phone vibrates
- unzip the recovery zip package and get the recovery.img file ,
- then move the recovery.img  boot.img and vendor.img to a sub-directory and  open terminal in their.
- Check that the phone is recognized by running `fastboot devices`
- Now we can flash Boot vendor and recovery using the command 
```
fastboot flash recovery recovery.img && fastboot flash vendor vendor.img && fastboot flash boot boot.img && fastboot reboot recovery 
```

### 2. Install Droidian in Recovery
Recovery:
- Go to `Wipe` and `Format data` (type yes)

PC:
- Connect the phone via USB
- The internal storage is now available over MTP from the PC
- Copy the downloaded files to the internal storage of the phone

Note: if you are having trouble with mtp, run the following command from the folder containig the droidian zip `adb push  droidian-rootfs-api28gsi-arm64*.zip /data/ droidian-rootfs-api28gsi-arm64 && adb push  fw_violet_miui_VIOLET_9.9.3*.zip /data/fw_violet_miui_VIOLET_9.9.3*.zip `

- Install firmware zip file
- Install zip file: `droidian-rootfs-api28gsi_arm64_YYYYMMDD.zip` 
- Install zip file: `droidian-devtools_arm64_YYYYMMDD.zip`(if you are not using nightly)

### 3.Untill adaption packages are available we need  a fix for droidian to boot
`
#### Disable crashing services
- on pc open terminal 
- conncet to recovery by running `adb shell`
- now paste the following lines:


```
mkdir /tmp/mpoint
mount /data/rootfs.img /tmp/mpoint
chroot /tmp/mpoint /bin/bash
export PATH=/usr/bin:/usr/sbin
systemctl mask systemd-journald
systemctl mask systemd-resolved
systemctl mask systemd-timesyncd
```
and reboot the device

#### Udev rules

we need to regenerate udev rule
- login to droidian using the following line (the password is 1234):

```
ssh droidian@10.15.19.82
```

- run the following command to generate udev rule

```
sudo -s

DEVICE=violet # replace with your device codename
cat /var/lib/lxc/android/rootfs/ueventd*.rc /vendor/ueventd*.rc | grep ^/dev | sed -e 's/^\/dev\///' | awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' >/etc/udev/rules.d/70-$DEVICE.rules
```
and reboot 

- The first boot may take longer, and at least one spontaneous reboot is expected during the process
- If all goes well, your phone will boot to the Droidian lock screen, the unlock code is `1234`
- Installation is complete we can see droidian lock screen now 

## Notes
### Porting status
testing ...
### Applications
You can find a list of mobile-friendly Linux applications at [LinuxPhoneApps](https://linuxphoneapps.org/)

### Update to bookworm
You can upgrade to the latest `bookworm` version of Droidian **after** doing all available updates from the `Software` application. Run this on the device itself:
```
sudo apt install droidian-upgrade-bookworm
sudo apt update
sudo apt upgrade
sudo apt update
sudo apt dist-upgrade
sudo apt clean
systemctl reboot
```

### wifi 
connect device to pc then `ssh droidian@10.15.19.82`

` touch /etc/resolv.conf && nano /etc/resolv.conf`
- and paste the following and save.
```  
nameserver 1.1.1.1
nameserver 1.0.0.1
```
- reboot 


## Credit
[mathew-dennis](https://gitlab.com/mathew-dennis)

[mardy](https://forums.ubports.com/user/mardy)

[Droidian](http://droidian.org/)

[Mobian](https://mobian-project.org/)

[UBports](https://ubuntu-touch.io/)



For further assistance, visit the [Droidian](https://t.me/droidianlinux) Telegram groups.
