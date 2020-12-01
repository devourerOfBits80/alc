# Firejail profile for NeoMutt
# Description: Text-based mailreader supporting MIME, GPG, PGP and threading
# Persistent Mutt definitions
include /etc/firejail/mutt.profile
# Persistent global definitions
include /etc/firejail/globals.local
# Persistent local customizations
include neomutt.local

noblacklist ${HOME}/.cache/neomutt
noblacklist ${HOME}/.config/neomutt
noblacklist ${HOME}/.neomuttrc
