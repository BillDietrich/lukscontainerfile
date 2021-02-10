#!/usr/bin/env sh

# install.sh
# Installs the Dolphin service menu "lukscontainerfile", which
# formats, mounts, and unmounts LUKS container files.
# This file must have execute permission set.
# Also may be called with "--remove" parameter to do uninstall ?

if [ $# -gt 0 ] && [ "$1" = '--remove' ]; then
  exec ./lukscontainerfile-uninstall.sh
  # should never get here
  RETVAL=$?
  exit $RETVAL
fi

set -o errexit
set -o nounset

echo "Installing the Dolphin service menu 'lukscontainerfile':"

DESTDIR="/usr/share/kservices5/ServiceMenus"
DESTDIRT="/usr/share/templates"

DESTDIR1=`dirname "$DESTDIR"`

sudo --validate

# if kservices5 doesn't exist, make it
if [ ! -d "$DESTDIR1" ]; then
  sudo mkdir "$DESTDIR1"
  sudo chown root:root "$DESTDIR1"
  sudo chmod 755 "$DESTDIR1"
fi

# if ServiceMenus doesn't exist, make it
if [ ! -d "$DESTDIR" ]; then
  sudo mkdir "$DESTDIR"
  sudo chown root:root "$DESTDIR"
  sudo chmod 755 "$DESTDIR"
fi

# if templates doesn't exist, make it
if [ ! -d "$DESTDIRT" ]; then
  sudo mkdir "$DESTDIRT"
  sudo chown root:root "$DESTDIRT"
  sudo chmod 755 "$DESTDIRT"
  sudo mkdir "$DESTDIRT"/.source
  sudo chown root:root "$DESTDIRT"
  sudo chmod 755 "$DESTDIRT"
fi

sudo cp lukscontainerfile.desktop "$DESTDIR"
sudo cp lukscontainerfile-format.sh "$DESTDIR"
sudo cp lukscontainerfile-mount.sh "$DESTDIR"
sudo cp lukscontainerfile-unmount.sh "$DESTDIR"
sudo cp lukscontainerfile-uninstall.sh "$DESTDIR"
sudo cp lukscontainerfile.xml "$DESTDIR"
sudo cp lukscontainerfilenew.desktop "$DESTDIRT"
sudo cp lukscontainerfile.luks "$DESTDIRT"/.source/lukscontainerfile.luks

sudo chmod +x "$DESTDIR"/lukscontainerfile-*.sh

echo "This may take 30 seconds or so; please be patient."
sudo xdg-mime install --novendor --mode system lukscontainerfile.xml
sudo xdg-icon-resource install --context mimetypes --novendor --size 48 --mode system lukscontainerfile-icon48x48.png lukscontainerfile

echo "Success !"

exit 0
