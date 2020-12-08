# Firejail profile for KVIrc
# Description: Qt based IRC client
# Persistent local customizations
include kvirc.local
# Persistent global definitions
include /etc/firejail/globals.local

noblacklist ${HOME}/.config/KVIrc
noblacklist ${DOWNLOADS}

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc
include disable-shell.inc
include disable-xdg.inc

include whitelist-var-common.inc

caps.drop all
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
nou2f
novideo
protocol unix,inet,inet6,netlink
seccomp
shell none
tracelog

private-bin kvirc,kvirc-config
private-cache
private-dev
private-tmp

# memory-deny-write-execute
