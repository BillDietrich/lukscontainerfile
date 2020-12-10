#!/usr/bin/env sh

# lukscontainerfile-mount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Format LUKS Container '$BASENAME'"

NMB=`kdialog --title "$TITLE" --inputbox "Size must be must be 40 MB or greater.  How many MB ? "`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

kdialog --title "$TITLE" --warningcontinuecancel "Sure you want to overwrite contents of '$FULLFILENAME' with $NMB MB LUKS2 container ?"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

USERPASSWD=`kdialog --title "$TITLE" --password "Formatting requires SUDO access.  Enter your password: "`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

echo "$USERPASSWD" | sudo --stdin --validate
RETVAL=$?
USERPASSWD=""

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Sudo failed (exit code $RETVAL)."
	exit $RETVAL
fi

CONTAINERPASSWD=`kdialog --title "$TITLE" --password "Enter passphrase to set on container '$BASENAME': "`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

dbusRef=`kdialog --title "$TITLE" --progressbar "" 6`
qdbus $dbusRef Set "" value 1
qdbus $dbusRef setLabelText "                luksFormat                "

dd if=/dev/zero of="$FULLFILENAME" bs=1 count=0 seek="$NMB"M
sudo rm -f "$FULLFILENAME.HeaderBackup"

sudo cryptsetup luksFormat --type luks2 --iter-time 4400 --key-file lukscontainerfile.tmp "$FULLFILENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Container luksFormat failed (exit code $RETVAL)."
	exit $RETVAL
fi

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
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Mkfs.btrfs failed (exit code $RETVAL)."
	exit $RETVAL
fi

qdbus $dbusRef Set "" value 5
qdbus $dbusRef setLabelText "                luksClose                "

sudo cryptsetup luksClose "$BASENAME"

if [ ! -d "/mnt/$BASENAME" ]; then
	sudo mkdir "/mnt/$BASENAME"
fi

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

qdbus $dbusRef close

kdialog --title "$TITLE" --msgbox "Success !  LUKS2 container '$BASENAME' has been formatted as Btrfs.  Now you can mount it.  And perhaps save file '$FULLFILENAME.HeaderBackup' somewhere safe."
