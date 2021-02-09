#!/usr/bin/env sh

# lukscontainerfile-unmount.sh
# This file must have execute permission set.
# Argument is container file full pathname.

#set -o errexit
set -o nounset

FULLFILENAME=$1
BASENAME=`basename "$FULLFILENAME" ".luks"`
TITLE="Unmount LUKS Container '$BASENAME'"

USERPASSWD=`kdialog --title "$TITLE" --password "Unmounting requires SUDO access.  Enter your password: "`
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

sudo umount "/mnt/$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --msgbox "Filesystem unmount failed (exit code $RETVAL)."
	exit $RETVAL
fi

sudo cryptsetup close "$BASENAME"
RETVAL=$?

if [ $RETVAL != "0" ]; then
	kdialog --title "$TITLE" --error "Container close failed (exit code $RETVAL)."
	exit $RETVAL
fi

kdialog --title "$TITLE" --msgbox "Success !  Container '$BASENAME' has been unmounted."

exit 0
