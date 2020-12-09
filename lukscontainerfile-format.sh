#!/usr/bin/env sh

# lukscontainerfile-mount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`

NMB=`kdialog --title "Format LUKS Container File $BASENAME" --inputbox "Size must be must be 109 MB or greater.  How many MB ? "`

kdialog --warningcontinuecancel "Sure you want to overwrite contents of $FULLFILENAME with $NMB MB LUKS2 container ?"

dd if=/dev/zero of="$FULLFILENAME" bs=1 count=0 seek="$NMB"M

USERPASSWD=`kdialog --title "Format LUKS Container File $BASENAME" --password "Formatting requires SUDO access.  Enter your password: "`

echo "$USERPASSWD" | sudo --stdin --validate
USERPASSWD=""

CONTAINERPASSWD=`kdialog --title "Format LUKS Container File $BASENAME" --password "Enter passphrase for container $BASENAME: "`
touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

dbusRef=`kdialog --title "Format LUKS Container File $BASENAME" --progressbar "" 6`
qdbus $dbusRef Set "" value 1
qdbus $dbusRef setLabelText "                luksFormat                "

sudo cryptsetup luksFormat --type luks2 --iter-time 4400 --key-file lukscontainerfile.tmp "$FULLFILENAME"

qdbus $dbusRef Set "" value 2
qdbus $dbusRef setLabelText "                luksHeaderBackup                "

sudo cryptsetup luksHeaderBackup "$FULLFILENAME" --header-backup-file "$FULLFILENAME.HeaderBackup"

sudo chown "$USER" "$FULLFILENAME.HeaderBackup"

qdbus $dbusRef Set "" value 3
qdbus $dbusRef setLabelText "                luksOpen                "

sudo cryptsetup --key-file lukscontainerfile.tmp luksOpen "$FULLFILENAME" "$BASENAME"

rm lukscontainerfile.tmp

qdbus $dbusRef Set "" value 4
qdbus $dbusRef setLabelText "                mkfs                "

sudo mkfs.btrfs -f -q --mixed --label "$BASENAME" "/dev/mapper/$BASENAME"

qdbus $dbusRef Set "" value 5
qdbus $dbusRef setLabelText "                luksClose                "

sudo cryptsetup luksClose "$BASENAME"

sudo mkdir "/mnt/$BASENAME"

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

qdbus $dbusRef close

kdialog --title "Format LUKS Container File $BASENAME" --msgbox "Success !  LUKS2 container $BASENAME has been formatted as Btrfs.  Now you can mount it."
