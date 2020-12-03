# Firejail profile for showfoto
# Description: Digital photo management application for KDE
# Persistent local customizations
include showfoto.local
# Persistent global definitions
include /etc/firejail/globals.local
# Persistent digikam definitions
include /etc/firejail/digikam.profile

noblacklist ${HOME}/.config/showfotorc
