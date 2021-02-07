#!/usr/bin/env sh

# lukscontainerfile-mount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Format LUKS Container '$BASENAME'"

FSTYPE=`kdialog --title "$TITLE" --radiolist "Filesystem type:" 1 "Btrfs not mixed (recommended if > 5 GB)" off 2 "Btrf mixed (recommended if < 5 GB)" off 3 "ext4" on`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

case $FSTYPE in
	1)
		MSG="File must be 125 MB or greater (filesystem will be 16 MB less).  How many MB for file ? "
		;;
	2)
		MSG="File must be 32 MB or greater (filesystem will be 16 MB less).  How many MB for file ? "
		;;
	3)
		MSG="File must be 17 MB or greater (filesystem will be 16 MB less).  How many MB for file ? "
		;;
	*)
		kdialog --title "$TITLE" --error "Invalid FSTYPE '$FSTYPE'."
		exit 1
		;;
esac

NMB=`kdialog --title "$TITLE" --inputbox "$MSG"`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

# could check NMB against size limit here, but too lazy

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
qdbus $dbusRef setLabelText "cryptsetup luksFormat --type luks2 '$FULLFILENAME'"

dd if=/dev/zero of="$FULLFILENAME" bs=1 count=0 seek="$NMB"M
sudo rm -f "$FULLFILENAME.HeaderBackup"

sudo cryptsetup luksFormat --type luks2 --iter-time 4400 --key-file lukscontainerfile.tmp "$FULLFILENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Container luksFormat failed (exit code $RETVAL)."
	exit $RETVAL
fi

qdbus $dbusRef Set "" value 2
qdbus $dbusRef setLabelText "cryptsetup luksHeaderBackup '$FULLFILENAME' --header-backup-file '$FULLFILENAME.HeaderBackup'"

sudo cryptsetup luksHeaderBackup "$FULLFILENAME" --header-backup-file "$FULLFILENAME.HeaderBackup"

sudo chown "$USER" "$FULLFILENAME.HeaderBackup"

qdbus $dbusRef Set "" value 3
qdbus $dbusRef setLabelText "cryptsetup luksOpen '$FULLFILENAME' '$BASENAME'"

sudo cryptsetup --key-file lukscontainerfile.tmp luksOpen "$FULLFILENAME" "$BASENAME"

rm lukscontainerfile.tmp

case $FSTYPE in
	1)
		MKFSCMD="mkfs.btrfs -f -q --label $BASENAME /dev/mapper/$BASENAME"
		;;
	2)
		MKFSCMD="mkfs.btrfs -f -q --mixed --label $BASENAME /dev/mapper/$BASENAME"
		;;
	3)
		MKFSCMD="mke2fs -t ext4 -F -q -L $BASENAME /dev/mapper/$BASENAME"
		;;
	*)
		kdialog --title "$TITLE" --error "Invalid FSTYPE '$FSTYPE'."
		exit 1
		;;
esac

qdbus $dbusRef Set "" value 4
qdbus $dbusRef setLabelText "$MKFSCMD"

sudo $MKFSCMD
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "'$MKFSCMD' failed (exit code $RETVAL)."
	exit $RETVAL
fi

qdbus $dbusRef Set "" value 5
qdbus $dbusRef setLabelText "luksClose '$BASENAME'"

sudo cryptsetup luksClose "$BASENAME"

if [ ! -d "/mnt/$BASENAME" ]; then
	sudo mkdir "/mnt/$BASENAME"
	RETVAL=$?

	if [ $RETVAL != "0" ]; then
		kdialog --title "$TITLE" --error "Making mountpoint '/mnt/$BASENAME' failed (exit code $RETVAL)."
		exit $RETVAL
	fi
fi

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

qdbus $dbusRef close

kdialog --title "$TITLE" --msgbox "Success !  LUKS2 container '$BASENAME' has been formatted with a filesystem.  Now you can mount it.  And perhaps save file '$FULLFILENAME.HeaderBackup' somewhere safe."
