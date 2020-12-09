#!/usr/bin/env sh

# lukscontainerfile-uninstall.sh
# Un-installs the Dolphin service menu "lukscontainerfile", which
# formats, mounts, and unmounts LUKS container files.
# This file must have execute permission set.

set -o errexit
set -o nounset

echo "Un-installing the Dolphin service menu 'lukscontainerfile':"

DESTDIR="$HOME/.local/share/kservices5/ServiceMenus"

sudo --validate
echo "This may take 30 seconds or so; please be patient."
sudo xdg-mime uninstall --mode system "$DESTDIR/lukscontainerfile.xml"

rm "$DESTDIR/lukscontainerfile.desktop"
rm "$DESTDIR/lukscontainerfile-format.sh"
rm "$DESTDIR/lukscontainerfile-mount.sh"
rm "$DESTDIR/lukscontainerfile-unmount.sh"
rm "$DESTDIR/lukscontainerfile-uninstall.sh"
rm "$DESTDIR/lukscontainerfile.xml"

echo "Success !"
