# Firejail profile for vokoscreenNG
# Description: Easy to use screencast creator
# Persistent local customizations
include vokoscreenNG.local
# Persistent global definitions
include /etc/firejail/globals.local

noblacklist ${VIDEOS}
noblacklist ${HOME}/.config/vokoscreenNG

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc
include disable-xdg.inc

include whitelist-usr-share-common.inc
include whitelist-var-common.inc

apparmor
caps.drop all
nodvd
nogroups
nonewprivs
noroot
notv
nou2f
protocol unix
seccomp
shell none
tracelog

private-cache
private-dev
private-tmp
