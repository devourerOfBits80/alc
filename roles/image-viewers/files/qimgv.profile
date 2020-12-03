# Firejail profile for qimgv
# Description: Qt5 image viewer with experimental webm playback
# Persistent local customizations
include qimgv.local
# Persistent global definitions
include /etc/firejail/globals.local

noblacklist ${HOME}/.config/qimgv
noblacklist ${HOME}/.cache/qimgv
noblacklist ${PICTURES}

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc
include disable-xdg.inc

include whitelist-var-common.inc

apparmor
caps.drop all
machine-id
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
nou2f
protocol unix,inet,inet6,netlink
seccomp
shell none
tracelog

# private-bin qimgv
private-cache
private-dev
private-etc alternatives,ca-certificates,crypto-policies,dconf,drirc,fonts,gtk-3.0,hosts,login.defs,machine-id,pki,resolv.conf,ssl
private-tmp
