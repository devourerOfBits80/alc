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
