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
