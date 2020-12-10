#!/usr/bin/env sh

# lukscontainerfile-uninstall.sh
# Un-installs the Dolphin service menu "lukscontainerfile", which
# formats, mounts, and unmounts LUKS container files.
# This file must have execute permission set.

set -o errexit
set -o nounset

echo "Un-installing the Dolphin service menu 'lukscontainerfile':"

DESTDIR="/usr/share/kservices5/ServiceMenus"
DESTDIRT="/usr/share/templates"

sudo --validate

echo "This may take 30 seconds or so; please be patient."
sudo xdg-icon-resource uninstall --context mimetypes --size 48 --mode system lukscontainerfile
sudo xdg-mime uninstall --mode system "$DESTDIR/lukscontainerfile.xml"

sudo rm "$DESTDIR/lukscontainerfile.desktop"
sudo rm "$DESTDIR/lukscontainerfile-format.sh"
sudo rm "$DESTDIR/lukscontainerfile-mount.sh"
sudo rm "$DESTDIR/lukscontainerfile-unmount.sh"
sudo rm "$DESTDIR/lukscontainerfile-uninstall.sh"
sudo rm "$DESTDIR/lukscontainerfile.xml"
sudo rm "$DESTDIRT/lukscontainerfilenew.desktop"
sudo rm "$DESTDIRT"/.source/lukscontainerfile.luks

echo "Success !"
