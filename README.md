# alc (Arch Linux constructor)

*alc* is a set of *[Ansible](https://www.ansible.com)* playbooks meant to make a post-installation process for the fresh installed *[Arch Linux](https://www.archlinux.org)* operating system. If you want to make a base installation of the *Arch Linux* OS in a pretty fast and easy way, you can just use the attached [INSTALLATION GUIDE](https://github.com/devourerOfBits80/alc/blob/master/INSTALLATION_GUIDE.md).

## How to perform post-installation steps

Running *alc* playbooks is pretty much simple. First, turn on the computer, log in as root to the newly installed system and update all packages.

> \$ pacman -Syyu

After that find out if you have installed *git* and *ansible* packages. If no, install them now.

> \$ pacman -S git ansible

Clone the *alc* repository. Go into its directory and (if required) update *git* submodules.

> \$ git clone --recursive <https://github.com/devourerOfBits80/alc.git>  
> \$ cd alc  
> \$ git submodule update --init --recursive (only for older versions of *Git*)

Finally, adjust the playbooks' execution settings to your expectations (see the [Playbooks' execution settings](#playbooks-execution-settings) section for more information). When you will be ready, run the first playbook via the *system.yml* file. It will have installed all required drivers and configured essential system settings.

> \$ ansible-playbook -i hosts -l desktop system.yml (for mobile devices replace *desktop* keyword with *portable*)

Subsequently, when the *system.yml* playbook execution is finished, reboot your machine and log into the created user account. The system is now fully installed, so logging into the root account will not be needed anymore. If you wish to install a desktop environment (only *KDE Plasma* is currently available), move the *alc* repository from the root into your local account, change its owner and execute the second playbook *plasma.yml* with the *--ask-become-pass* argument.

> \$ sudo cp -R /root/alc ~/alc  
> \$ sudo rm -rf /root/alc  
> \$ sudo chown -R *USERNAME*:*GROUP* ~/alc (use a proper username and group)  
> \$ cd alc  
> \$ ansible-playbook -i hosts -l desktop --ask-become-pass plasma.yml (use *portable* instead of *desktop* for mobile devices)

## Playbooks' execution settings

*alc* has many playbooks' execution settings that can be pre-configured. They are mostly available in the *group_vars/all* file. Some of them (especially the most important) have been described below.

### Hostname and user account details

The machine unique name (the *HOSTNAME* variable) and user account details must be defined. *alc* will automatically create a user account. The only one thing needed to do is to set the *USER.NAME*, *USER.GROUP* and *USER.FULL_NAME* variables as expected.

### Bootloader (Secure Boot for the rEFInd boot manager)

There is a possibility to install a *Secure Boot* (with using a *Machine Owner Key*) for *UEFI* mode with the *rEFInd* bootloader, but this option is disabled by default because it requires some additional actions. If you currently have installed the *rEFInd* boot manager and you want to install and configure a *Secure Boot* on your machine, please follow the steps:

- First of all, disable temporarily *Secure Boot* in *BIOS* (it should happen before execution the *system.yml* playbook).
- Edit the *group_vars/all* file and set the *SECURE_BOOT_ENABLED* variable as *True*.
- Run the *system.yml* playbook and wait until the installation has been finished. Reboot your machine, enter the *BIOS* and set the *Secure Boot* option back to *Enabled*.
- Once the *rEFInd* boot manager will appear on the screen, choose the yellow key icon and launch the *MokManager*.
- In the *MokManager* application select option *Enroll key from disk*. After that choose the proper partition and add the *refind_local.cer* certificate to the *MoKList* (the file should be available inside the *rEFInd's* installation directory (eg. */boot/EFI/refind/keys/refind_local.cer*).
- Go back to the *MokManager* main menu and select *Continue boot* option. Your machine should boot now protected by the *Secure Boot*. If at the list of the boot order there are displayed duplicate entries for the *rEFInd* manager, you can easily remove the unused one via the *efibootmgr* command.

> \$ efibootmgr -b XXXX -B (where XXXX is an identifire of the boot number)

### Drives, hardware and video drivers

*alc* is able to install a complete set of machine drivers, but some details have to be provided before launching the *system.yml* playbook. If you are going to make an installation process on a virtual machine, please omit the *-l desktop* parameter in the playbook execution command.

For desktops, only one *GPU* driver can be installed. By default, it is a driver for discrete graphics card however, if you have only an internal, integrated graphics card, edit the *group_vars/desktop* file, remove the *DISCRETE_GPU_DRIVERS* list variable and add the *INTEGRATED_GPU_DRIVERS* list with required drivers.

In the case of laptops (notebooks) with the *NVIDIA* graphics card, both types of *GPU* can be handled out of the box, because together with drivers there will be installed the *Bumblebee* software which provides support for the *NVIDIA Optimus* technology. However, if there is only one graphics card on your *PC*, remove the unused variable (list of drivers) in the *group_vars/portable* file.

The *NVIDIA Optimus* technology feature can be tested directly from the console of the already installed system with the command:

> \$ optirun glxspheres64 (should be displayed using the *NVIDIA* graphics card)

There is also a possibility to enable or disable support for optical disk drives, *Bluetooth* devices, and *MTP* devices like cell phones or media players.

Some older machines have problems with too slow launching the desktop environment. It is a very isolated case, but if you are frustrated, installing the *Haveged* and enabling its service should resolve your issue.

> \$ pacman -S haveged  
> \$ systemctl start haveged.service  
> \$ systemctl enable haveged.service

### AppArmor and Uncomplicated Firewall

For machine protection, *alc* will have installed and configured: *AppArmor*, which is a *Mandatory Access Control* system, implemented upon the *Linux Security Modules*; and a popular net filter manager, *Uncomplicated Firewall*. Both these security utils can be separately disabled in the *group_vars/all* file, but it is strongly recommended to leave them enabled as default. In the case of the firewall, there is also a possibility to declare your own trusted addresses and subnets.

### Peripheral devices (printers and scanners)

*alc* can configure a network area and support for peripheral devices like printers (*CUPS*) or scanners (*SANE*). There are several related parameters in the *group_vars/all* file, that can be adjusted according to the user's expectations. Among other things, it is a possibility to declare additional (custom) drivers using the *AUR_CUSTOM_PRINTER_DRIVERS* or the *AUR_CUSTOM_SCANNER_DRIVERS* list variable.

### Encrypted communication (GnuPG and SSH)

To protect the machine communication, *alc* configures the *GnuPG* and the *OpenSSH* services. The first of them does not have configuration parameters, but the second one does, and a few of these options are quite important. For example: via the *SSH_DAEMON_ENABLED* variable, you can enable or disable an *SSH* server; via the *FORCE_SSH_PUBLIC_KEY_AUTH* variable, you can block or unblock the password authentication on the *SSH* server; finally, via the *SSH_AGENT_ENABLED* variable, you can activate or deactivate an *SSH Agent*. Besides, by adding the *SSH_SERVER_PORT* variable to the *group_vars/all* file, there is a possibility to change the *SSH* server listening port (default 22).

For using encrypted communication, it is required to have a pair of public and private keys. To generate them, you can use the commands below:

- ***Generating a GnuPG key pair***

> \$ gpg --full-gen-key (for getting alternative ciphers, add the *--expert* option)

- ***Generating an SSH key pair***

> \$ ssh-keygen -C "\$(whoami)@\$(uname -n)-\$(date -I)" (for the Ed25519 key type, add the *-t ed25519* option)  
> \$ chmod 400 ~/.ssh/id_rsa (for the Ed25519 key, use the *id_ed25519* file)

To start the encrypted communication between two machines, securely and conveniently, using the SSH protocol without allowing the password authentication, send the public key to the remote server, run the SSH Agent on the local machine, and add to its the private key.

> \$ ssh-copy-id -i ~/.ssh/id_rsa.pub username@remote-server.org (for a non-default SSH server port, use *-p {port}* option)  
> \$ ssh-agent  
> \$ eval \$(ssh-agent)  
> \$ ssh-add ~/.ssh/id_rsa

### Backup (rdiff-backup)

*alc* supports user accounts incremental backups, but this option is disabled by default because locally it does not make especial sense if you have not installed a secondary drive. To enable this feature, set the *USER_ACCOUNTS_BACKUP* variable value as *True* and make sure that the *BACKUP_LOCATION* variable has a correct path to the local or remote destination directory. There is also a possibility to define backup jobs later, directly from the user account, as its cron jobs. For example, if you want to backup your *Documents* directory every 10 minutes, you can do the following:

> \$ fcrontab -e (text editor should open)  
> \*/10 \* \* \* \* /usr/bin/rdiff-backup /home/{user}/Documents /path/to/backup (type, save and exit)

For making a full system backup, the *rsync* tool can be used instead of *rdiff-backup*. Remember that the command below has to be executed with the root privileges.

> \$ rsync -aAXHv --exclude={"/dev/\*","/proc/\*","/sys/\*","/tmp/\*","/run/\*","/mnt/\*","/media/\*","/lost+found"} / /path/to/backup

### Firejail

In the second phase of the post-installation process (the desktop environment playbook execution, like *plasma.yml*), *alc* will install the *Firejail*, which is a *SUID* sandbox program. If the *AppArmor* has been installed in the previous phase, *Firejail* will integrate with it and highly increase the system security. In that case, most of the applications will be permanently launching inside the sandbox. To avoid this effect (not recommended), disable the *Firejail* in the *group_vars/all* file using the *FIREJAIL_ENABLED* boolean variable.

### Desktop Environment

*alc* supports installation and configuration of a desktop environment (currently only *KDE Plasma* is available). In this area, there are a few parameters that you may want to change, but the most important is keyboard mapping, a default set to the Polish language. If you wish to set any other language than English, change the *X_KEYBOARD_MAP* variable value to your expectations. Otherwise (for the English language), you can comment on this line. The same rule is related to the *CALENDAR_HOLIDAY_REGIONS* variable. In the case of the commented line, it will have used the United States region (*us_en-us*).

*KDE Plasma* brings with the *KDE Wallet Manager*, where your passwords will be store. To add a new *SSH* key and remember its password in the wallet, use the following command:

> \$ ssh-add /path/to/new/key \< /dev/null

Keep in mind that if you want to unlock your *SSH* keys during login, all of them with a name different than *~/.ssh/id_rsa* should be additionally declared in the *~/.config/autostart-scripts/ssh-add.sh* file.

### Password Manager

There are available two additional password managers, *pass* and *KeePass* (the *KeePassXC* version), but none of them are applying by default because the desktop environment has an integrated wallet/keyring. To enable the expected one, please uncomment the *PASSWORD_MANAGER* variable in the *group_vars/all* file and set its value as you wish.

To quickly initialize a new password store for the *pass*, generate a [*GnuPG* key pair](#encrypted-communication-gnupg-and-ssh) (if you have not it yet) and finally use the *gpg-id* or *email* to create the encrypted store. Of course, this requires to finalize the desktop environment playbook first.

> \$ pass init \<*gpg-id* or *email*\>
