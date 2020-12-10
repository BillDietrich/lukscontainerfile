#!/usr/bin/env sh

# install.sh
# Installs the Dolphin service menu "lukscontainerfile", which
# formats, mounts, and unmounts LUKS container files.
# This file must have execute permission set.

set -o errexit
set -o nounset

echo "Installing the Dolphin service menu 'lukscontainerfile':"

DESTDIR="$HOME/.local/share/kservices5/ServiceMenus"

DESTDIR1=`dirname "$DESTDIR"`

# if kservices5 doesn't exist, make it
if [ ! -d "$DESTDIR1" ]; then
  mkdir "$DESTDIR1"
fi

# if ServiceMenus doesn't exist, make it
if [ ! -d "$DESTDIR" ]; then
  mkdir "$DESTDIR"
fi

cp lukscontainerfile.desktop "$DESTDIR"
cp lukscontainerfile-icon48x48.png "$DESTDIR"
cp lukscontainerfile-format.sh "$DESTDIR"
cp lukscontainerfile-mount.sh "$DESTDIR"
cp lukscontainerfile-unmount.sh "$DESTDIR"
cp lukscontainerfile-uninstall.sh "$DESTDIR"
cp lukscontainerfile.xml "$DESTDIR"

chmod +x "$DESTDIR"/lukscontainerfile-*.sh

sudo --validate
echo "This may take 30 seconds or so; please be patient."
sudo xdg-mime install --novendor --mode system lukscontainerfile.xml
sudo xdg-icon-resource install --context mimetypes --novendor --size 48 --mode system "$DESTDIR"/lukscontainerfile-icon48x48.png lukscontainerfile

echo "Success !"
