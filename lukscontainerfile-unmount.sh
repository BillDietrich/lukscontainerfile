#!/usr/bin/env sh

# lukscontainerfile-unmount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`

USERPASSWD=`kdialog --title "Unmount LUKS Container File $BASENAME" --password "Unmounting requires SUDO access.  Enter your password: "`

echo "$USERPASSWD" | sudo --stdin --validate
USERPASSWD=""

sudo umount "/mnt/$BASENAME"

sudo cryptsetup close "$BASENAME"

kdialog --title "Unmount LUKS Container File $BASENAME" --msgbox "Success !  Container $BASENAME has been unmounted."
