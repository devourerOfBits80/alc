# Arch Linux Quick Installation Guide

Before using the *alc* playbooks, you have to install a fresh instance of the *Arch Linux* OS. To achieve the requirement, you can use this quick guide that will show you step by step what you need to do. Otherwise, you can go to the official [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) page and install the system on your own. Eventually, you can use the *[Anarchy Installer](https://anarchyinstaller.org)*, a simple and intuitive Terminal-based (*TUI*) *Arch Linux* OS installer, but then keep in mind that you should install only the basic system without a desktop environment.

## Prerequisites

Boot your machine with using the *Arch Linux* installation media. You will be logged in directly to the default virtual console as a root.

### Select the boot mode

Verify the boot mode to know if you should use *UEFI* or *BIOS*. List the *efivars* directory. If it exists, the system may be booted in *UEFI* mode, otherwise in *BIOS*.

> \$ ls /sys/firmware/efi/efivars

### Determine the SWAP size

There are many opinions and a lot of confusion about the *SWAP* size and its usability, especially when the machine has lots of *RAM*. In this guide, it has been assumed that *SWAP* is always required and its size should be related to the size of *RAM* and computed according to the information included in the table below.

Display the size of *RAM* (result will have been displayed in MB in the total column but if you want to have the result in GB, replace *-m* argument with *-g*).

> \$ free -m

Use the result to determine the *SWAP* size.

|RAM size|SWAP size (without hibernation)|SWAP size (with hibernation)|
|-------:|------------------------------:|---------------------------:|
|2GB     |1GB                            |3GB                         |
|3GB     |2GB                            |5GB                         |
|4GB     |2GB                            |6GB                         |
|6GB     |2GB                            |8GB                         |
|8GB     |3GB                            |11GB                        |
|12GB    |3GB                            |15GB                        |
|16GB    |4GB                            |20GB                        |
|32GB    |6GB                            |38GB                        |
|64GB    |8GB                            |72GB                        |

### Prepare disk for partitioning

In the case when hard drive you are going to use for the system installation contains previously created partitions, you can securely wipe the disk by writing a zero byte to every addressable location. It can take a while.

> \$ dd if=/dev/zero of=/dev/sdX bs=4096 status=progress

Or with the random stream.

> \$ dd if=/dev/urandom of=/dev/sdX bs=4096 status=progress

Instead of the */dev/sdX* phrase, use the proper device file (eg. */dev/sda*). To list all available block devices use the command.

> \$ lsblk -f

For *SSD* drives, it is much better to delete only partitions without disk wiping.

> \$ wipefs -a /dev/sdX

### Connect to the internet

In most cases, the network connection via the ethernet cable should work out of the box. The easiest way to configure the network connection via the wireless *LAN* is using the *iwctl* client program from the *[iwd](https://wiki.archlinux.org/index.php/Iwd#iwctl)* package.

> \$ iwctl (launch an interactive prompt)  
> \[iwd\]\# device list  
> \[iwd\]\# station *device* scan  
> \[iwd\]\# station *device* get-networks (list all available *WiFi* networks)  
> \[iwd\]\# station *device* connect *SSID* (connect to expected network)  
> \[iwd\]\# exit

The connection status may be verified with *ping* command.

> \$ ping -c 3 8.8.8.8

### Update the system clock

Use *timedatectl* to ensure the system clock is up to date.

> \$ timedatectl set-ntp true

## Partitioning

It is a good idea to leave the recommended minimum amount of free space around 15% to 20% of the disk size in the case of *SSD* drives. To list partition layout on all block devices use the *parted* command.

> \$ parted -l

### Create the partitions

- ***BIOS mode with MBR partition table***

The suggested layout.

|Mount point on the installed system|Partition|Partition type     |Suggested size         |
|:----------------------------------|:--------|:------------------|:----------------------|
|/ (boot flag)                      |/dev/sda1|Linux \[ext4\]     |32GB (32768MB)         |
|\[SWAP\]                           |/dev/sda2|Linux swap \[swap\]|depends on the RAM size|
|/home                              |/dev/sda3|Linux \[ext4\]     |remainder of the device|

> \$ parted -s /dev/sda mklabel msdos  
> \$ parted -s /dev/sda mkpart primary ext4 1MiB 32769MiB  
> \$ parted -s /dev/sda set 1 boot on  
> \$ parted -s /dev/sda mkpart primary linux-swap 32769MiB 36865MiB (in the case of *SWAP* 4GB)  
> \$ parted -s /dev/sda mkpart primary ext4 36865MiB 85% (100% for *HDD*)

You can also use the *Linux* partition table editor to modify or verify the partitions.

> \$ cfdisk /dev/sda

- ***UEFI mode with GPT partition table***

The suggested layout.

|Mount point on the installed system|Partition|Partition type              |Suggested size         |
|:----------------------------------|:--------|:---------------------------|:----------------------|
|/boot                              |/dev/sda1|EFI System \[fat32\]        |512MB                  |
|/                                  |/dev/sda2|Linux root (x86-64) \[ext4\]|32GB (32768MB)         |
|\[SWAP\]                           |/dev/sda3|Linux swap \[swap\]         |depends on the RAM size|
|/home                              |/dev/sda4|Linux filesystem \[ext4\]   |remainder of the device|

> \$ parted -s /dev/sda mklabel gpt  
> \$ parted -s /dev/sda mkpart primary fat32 1MiB 513MiB  
> \$ parted -s /dev/sda set 1 esp on  
> \$ parted -s /dev/sda mkpart primary ext4 513MiB 33281MiB  
> \$ parted -s /dev/sda mkpart primary linux-swap 33281MiB 37377MiB (in the case of *SWAP* 4GB)  
> \$ parted -s /dev/sda mkpart primary ext4 37377MiB 85% (100% for *HDD*)

To launch the *Linux* partition table editor use the command.

> \$ cfdisk /dev/sda

### Encrypt the home partition

For the *UEFI* mode replace */dev/sda3* with */dev/sda4*. Create and remember the encryption passphrase.

> \$ cryptsetup -y -v luksFormat --type luks1 /dev/sda3  
> \$ cryptsetup open /dev/sda3 home

### Format the partitions and initialize the SWAP

- ***BIOS mode***

> \$ mkfs.ext4 -L ARCH /dev/sda1  
> \$ mkswap -L SWAP /dev/sda2  
> \$ mkfs.ext4 -L HOME /dev/mapper/home  
> \$ swapon /dev/sda2

- ***UEFI mode***

> \$ mkfs.vfat -F32 -n ESP /dev/sda1  
> \$ mkfs.ext4 -L ARCH /dev/sda2  
> \$ mkswap -L SWAP /dev/sda3  
> \$ mkfs.ext4 -L HOME /dev/mapper/home  
> \$ swapon /dev/sda3

### Part and encrypt an additional drive

If you have installed an additional disk for your data, you can part and encrypt it just in this place. It will be convenient to use the same passphrase which has been applyed to encryption of the home partition.

> \$ parted -s /dev/sdb mklabel msdos (gpt for *UEFI*)  
> \$ parted -s /dev/sdb mkpart primary ext4 1MiB 85% (100% for *HDD*)  
> \$ cryptsetup -y -v luksFormat --type luks1 /dev/sdb1  
> \$ cryptsetup open /dev/sdb1 data  
> \$ mkfs.ext4 -L DATA /dev/mapper/data

### Mount the file systems

- ***BIOS mode***

> \$ mount /dev/sda1 /mnt  
> \$ mkdir /mnt/home  
> \$ mount /dev/mapper/home /mnt/home

- ***UEFI mode***

> \$ mount /dev/sda2 /mnt  
> \$ mkdir /mnt/boot  
> \$ mount /dev/sda1 /mnt/boot  
> \$ mkdir /mnt/home  
> \$ mount /dev/mapper/home /mnt/home

- ***Additional drive (if installed)***

> \$ mkdir /mnt/data  
> \$ mount /dev/mapper/data /mnt/data

## Instalation

### Select the mirrors

Packages to be installed must be downloaded from mirror servers, which are defined in the *mirrorlist* file. If you need, please edit it now.

> \$ nano /etc/pacman.d/mirrorlist

### Install base packages

Use the *pacstrap* script to install the *base* and *base-devel* package groups, *linux* kernel, *linux* firmware and some additional packages.

> \$ pacstrap /mnt base base-devel linux linux-firmware nano vim git ansible (for *LTS* kernel replace *linux* with *linux-lts* package)

## Configuration

### Generate and verify fstab

> \$ genfstab -U /mnt >> /mnt/etc/fstab (*-U* parameter should be skipped in case of the BIOS boot mode)  
> \$ nano /mnt/etc/fstab (check if everything is ok)

For machines with *RAM* size less than 8GB, it is a good idea to add configuration for the *tmpfs*.

> \$ echo "tmpfs /tmp tmpfs rw,nodev,noexec,nosuid,size=4G 0 0" >> /mnt/etc/fstab

### Change root into the new system

> \$ arch-chroot /mnt

### Add configuration to automatically mount the encrypted partition(s) at boot time

Generate a keyfile to decrypt the encrypted partition(s) during boot.

> \$ dd bs=512 count=8 if=/dev/urandom of=/etc/crypttab.key  
> \$ chmod 0400 /etc/crypttab.key

Update the encrypted partition(s) with the created keyfile and add proper entries to the *crypttab* file.

- ***BIOS mode***

> \$ cryptsetup luksAddKey /dev/sda3 /etc/crypttab.key  
> \$ echo "home /dev/sda3 /etc/crypttab.key luks" >> /etc/crypttab

- ***UEFI mode***

> \$ cryptsetup luksAddKey /dev/sda4 /etc/crypttab.key  
> \$ HOMEUUID=\$(blkid /dev/sda4 | awk '\{print \$2\}' | cut -d '"' -f2)  
> \$ echo "home UUID=\$HOMEUUID /etc/crypttab.key luks" >> /etc/crypttab

If the additional drive has been installed and encrypted, follow the steps.

> \$ cryptsetup luksAddKey /dev/sdb1 /etc/crypttab.key

- ***BIOS mode***

> \$ echo "data /dev/sdb1 /etc/crypttab.key luks" >> /etc/crypttab

- ***UEFI mode***

> \$ DATAUUID=\$(blkid /dev/sdb1 | awk '\{print \$2\}' | cut -d '"' -f2)  
> \$ echo "data UUID=\$DATAUUID /etc/crypttab.key luks" >> /etc/crypttab

### Set the time zone

> \$ ln -sf /usr/share/zoneinfo/\{Region\}/\{City\} /etc/localtime  
> \$ hwclock --systohc

### Configure localization

Uncomment *en_US.UTF-8 UTF-8* and other needed locales (eg. *pl_PL.UTF-8 UTF-8*) in the *locale.gen* file. After that generate them.

> \$ nano /etc/locale.gen (here and below you can already use *vim* editor instead of *nano*)  
> \$ locale-gen

Create the *locale.conf* file and set the *LANG* variable accordingly (for example, Polish).

> \$ echo LANG=pl_PL.UTF-8 > /etc/locale.conf

Set the keyboard layout if you need.

> \$ echo KEYMAP=pl > /etc/vconsole.conf  
> \$ echo FONT=Lat2-Terminus16.psfu.gz >> /etc/vconsole.conf  
> \$ echo FONT_MAP=8859-2 >> /etc/vconsole.conf

### Add network configuration

Install required packages.

> \$ pacman -S net-tools wireless_tools dialog wpa_supplicant inetutils networkmanager

In the case of *Wi-Fi* devices, you will sometimes need to install additional packages (drivers). For example, the newer *Broadcom* chipsets like *BCM4360* require to install the *Broadcom 802.11 Linux STA* wireless driver.

> \$ pacman -S broadcom-wl

Create the *hostname* file. Replace the *MYHOSTNAME* phrase with the expected name of your machine.

> \$ hostnamectl set-hostname MYHOSTNAME

Add matching entries to the *hosts* file.

> \$ echo "127.0.0.1 localhost" >> /etc/hosts  
> \$ echo "::1 localhost" >> /etc/hosts  
> \$ echo "127.0.1.1 MYHOSTNAME.localdomain MYHOSTNAME" >> /etc/hosts

Enable the *NetworkManager* service.

> \$ systemctl enable NetworkManager

### Recreate the initramfs image (only if hibernation is supported)

> \$ sed -i 's/^HOOKS=.\*/HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)/' /etc/mkinitcpio.conf  
> \$ mkinitcpio -P

### Set the root password

> \$ passwd

### Configure the boot loader

- ***BIOS mode boot loader***

Install the *GRUB* package.

> \$ pacman -S grub

Update configuration and install *GRUB*.

> \$ sed -i 's/^GRUB_TIMEOUT=.\*/GRUB_TIMEOUT=2/' /etc/default/grub  
> \$ sed -i 's/^GRUB_CMDLINE_LINUX=.\*/GRUB_CMDLINE_LINUX=\"resume=\/dev\/sda2\"/' /etc/default/grub (only if hibernation is supported)  
> \$ grub-install --recheck /dev/sda  
> \$ grub-mkconfig -o /boot/grub/grub.cfg

- ***UEFI mode boot loader***

Install required packages.

> \$ pacman -S refind efitools

Install *rEFInd*.

> \$ refind-install

For machines which have issues with writing to the *NVRAM* via the *efibootmgr*, use command.

> \$ refind-install --usedefault /dev/sda1

Add the *rEFInd* configuration. For *LTS* kernel, replace the *initramfs-linux* expression with *initramfs-linux-lts*. In the case when hibernation is not supported, skip the *resume=PARTUUID=\$SWAPPARTUUID* expression wherever it occurs.

> \$ sed -i 's/^timeout .\*/timeout 2/' /boot/EFI/refind/refind.conf  
> \$ ROOTPARTUUID=\$(blkid /dev/sda2 | awk '\{sub(/.\*PARTUUID=/,\_,\$0); print\}' | cut -d '"' -f2)  
> \$ SWAPPARTUUID=\$(blkid /dev/sda3 | awk '\{sub(/.\*PARTUUID=/,\_,\$0); print\}' | cut -d '"' -f2) (only if hibernation is supported)  
> \$ echo "\\"Boot using default options\\" \\"root=PARTUUID=\$ROOTPARTUUID rw add_efi_memmap quiet loglevel=3 resume=PARTUUID=\$SWAPPARTUUID initrd=initramfs-linux.img\\"" > /boot/refind_linux.conf  
> \$ echo "\\"Boot using fallback initramfs\\" \\"root=PARTUUID=\$ROOTPARTUUID rw add_efi_memmap initrd=initramfs-linux-fallback.img\\"" >> /boot/refind_linux.conf  
> \$ echo "\\"Boot to terminal\\" \\"root=PARTUUID=\$ROOTPARTUUID rw add_efi_memmap quiet loglevel=3 resume=PARTUUID=\$SWAPPARTUUID initrd=initramfs-linux.img systemd.unit=multi-user.target\\"" >> /boot/refind_linux.conf

### Exit the chroot environment and reboot machine

> \$ exit  
> \$ umount -R /mnt  
> \$ reboot

## Post-configuration

If you need to configure the *Wi-Fi* connection, please login as a root and use the command.

> \$ HISTFILE= ; nmcli dev wifi connect \[SSID\] password \[password\]  
> \$ history -c
