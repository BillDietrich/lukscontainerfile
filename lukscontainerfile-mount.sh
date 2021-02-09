#!/usr/bin/env sh

# lukscontainerfile-mount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Mount LUKS Container '$BASENAME'"

USERPASSWD=`kdialog --title "$TITLE" --password "Mounting requires SUDO access.  Enter your password: "`
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

CONTAINERPASSWD=`kdialog --title "$TITLE" --password "Enter passphrase for container '$BASENAME': "`
RETVAL=$?

if [ $RETVAL != "0" ]; then
	exit $RETVAL
fi

touch lukscontainerfile.tmp
chmod 600 lukscontainerfile.tmp
echo -n "$CONTAINERPASSWD" >lukscontainerfile.tmp

sudo cryptsetup luksOpen --key-file lukscontainerfile.tmp "$FULLFILENAME" "$BASENAME"
RETVAL=$?

rm lukscontainerfile.tmp

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Decryption failed (exit code $RETVAL)."
	exit $RETVAL
fi

if [ ! -d "/mnt/$BASENAME" ]; then
	sudo mkdir "/mnt/$BASENAME"
	RETVAL=$?

	if [ $RETVAL != "0" ]; then
		kdialog --title "$TITLE" --error "Making mountpoint '/mnt/$BASENAME' failed (exit code $RETVAL)."
		exit $RETVAL
	fi
fi

sudo mount -o defaults,noatime "/dev/mapper/$BASENAME" "/mnt/$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Filesystem mount failed (exit code $RETVAL)."
	exit $RETVAL
fi

sudo chown "$USER" "/mnt/$BASENAME"

sudo chmod 700 "/mnt/$BASENAME"

kdialog --title "$TITLE" --msgbox "Success !  Container '$BASENAME' has been mounted."

exit 0
