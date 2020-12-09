#!/usr/bin/env sh

# lukscontainerfile-mount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`

USERPASSWD=`kdialog --title "Mount LUKS Container File $BASENAME" --password "Mounting requires SUDO access.  Enter your password: "`

echo "$USERPASSWD" | sudo --stdin --validate
USERPASSWD=""

CONTAINERPASSWD=`kdialog --title "Mount LUKS Container File $BASENAME" --password "Enter passphrase for container $BASENAME: "`
touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

sudo cryptsetup luksOpen --key-file lukscontainerfile.tmp "$FULLFILENAME" "$BASENAME"

rm lukscontainerfile.tmp

sudo mount -o defaults,noatime "/dev/mapper/$BASENAME" "/mnt/$BASENAME"

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

kdialog --title "Mount LUKS Container File $BASENAME" --msgbox "Success !  Container $BASENAME has been mounted."
