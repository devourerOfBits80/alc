# Firejail profile for soundKonverter
# Description: Front-end to various audio converters
# Persistent local customizations
include soundkonverter.local
# Persistent global definitions
include /etc/firejail/globals.local

noblacklist ${HOME}/.config/soundkonverterrc
noblacklist ${HOME}/.local/share/soundkonverter
noblacklist ${DOWNLOADS}
noblacklist ${MUSIC}

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc
include disable-xdg.inc

include whitelist-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

apparmor
caps.drop all
ipc-namespace
machine-id
no3d
nodvd
nogroups
nonewprivs
noroot
nosound
notv
nou2f
novideo
protocol unix,inet,inet6,netlink
seccomp
shell none

private-cache
private-dev
private-tmp
