# README for "lukscontainerfile" Dolphin Service Menu

This is a "Service Menu" extension for KDE's Dolphin file manager, to handle LUKS-encrypted container files.

Dolphin has native features to handle LUKS-encrypted volumes (disks, partitions), but not to handle LUKS-encrypted container files.

This extension creates LUKS2 container files with ext4 or Btrfs filesystem inside, and mounts/unmounts LUKS container files. The mount/unmount should work regardless of the container's LUKS version or type of filesystem inside.  So you could create a LUKS container file manually if you wished, and still use the mount/unmount actions of this extension.

You must have "sudo" permission to use this extension.

This software works on Linux only, not any other platform where Dolphin runs.

Created 2020 by Bill Dietrich ([bill@billdietrich.me](bill@billdietrich.me), [https://www.billdietrich.me](https://www.billdietrich.me))

Source code is at [https://github.com/BillDietrich/lukscontainerfile](https://github.com/BillDietrich/lukscontainerfile)


## Pre-Installation

You must have installed Dolphin file manager, X desktop utilities, and (if you want to use it) Btrfs:

```
dolphin --version
xdg-mime --version
btrfs --version		# if this fails, install "btrfs-progs"
```


## Install

```
# copy the files to your disk, then:
chmod +x install.sh
./install.sh
```


## Un-install

```
cd /usr/share/kservices5/ServiceMenus
./lukscontainerfile-uninstall.sh
```


## Use

In Dolphin file manager, right-click on a SOMENAME.luks file, and the context menu will include menu items "Format LUKS2 container file", "Mount LUKS container file", and "Unmount LUKS container file".

All operations require you to have "sudo" permission.

To use the context menu items:

* Create New / LUKS Container File ...

    In Dolphin file manager, right-click on some empty space in a directory, select menu-item "Create New / LUKS Container File ...", set filename to SOMENAME.luks, and the file will be created with placeholder contents.  In CLI, you could do "touch SOMENAME.luks".  In Dolphin file manager, you could do "Create new text file", name it "SOMENAME", then rename it to "SOMENAME.luks".  The filename must end with ".luks", and the basename should be alphanum (well, valid as a filesystem label, anyway).

	File basename (without ".luks") will be used as label of filesystem, so for ext4 filesystem it must be 16 characters or less.  I don't know what the length limit is for Btrfs, and what types of chars can be in a label for any type of filesystem.

* Format LUKS2 container file
    
	Right-click on the .luks file you created, and select the "Format LUKS2 container file" menu item.  Follow the dialogs, giving information and passwords as needed.  The file will be formatted as a LUKS2 container with an ext4 or Btrfs filesystem inside, a header backup file called SOMENAME.luks.HeaderBackup will be created, and a mount-point /mnt/TEST will be created.

	Security note: As the container is being LUKS-formatted, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Note: You are free to delete the header backup file if you wish.  But it is a good idea instead to save it somewhere safe.  If the header of the container file gets damaged, you may be able to use the header backup file to repair it.

	Note: Every time you format a container file, a mount-point such as /mnt/TEST will be created for it.  But when you delete a container file, the mount-point is not deleted.  This could lead to clutter (not very serious) in /mnt.  You could delete the old mount-points (they're just directories) manually, for the ones that correspond to container files you've deleted.

* Mount LUKS container file

	Right-click on the .luks file, select the "Mount LUKS container file" menu item, give the required passwords, and the existing SOMENAME.luks container file will be mounted (with added flag noatime) on mount-point /mnt/SOMENAME.

	Security note: As the container is being LUKS-opened, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Security note: The mount-point for the container is owned by current user and has 700 permissions (usable only by current user) when mounted.  If you want to change this, you can edit the files lukscontainerfile-format.sh and lukscontainerfile-mount.sh in /usr/share/kservices5/ServiceMenus

* Unmount LUKS container file

	Right-click on the .luks file, select the "Unmount LUKS container file" menu item, give the required password, and the existing SOMENAME.luks container file will be unmounted from mount-point /mnt/SOMENAME.


## Status

### 1.0.0 (12/2020)
* Tested only on Kubuntu 20.10 with Dolphin 20.08.2.

### 1.1.0 (12/2020)
* Tweaked README.
* New icon for extension and format action.
* Fixed icon-setting in MIME database.

### 1.2.0 (12/2020)
* Added a template under the "Create New" sub-menu.  Was not able to make it do "create file and format it" in one operation, so still have to have a separate Format menu item.
* Changed files location from ~/.local/share/ to /usr/share/ because I couldn't get templates to work under ~, and anyway this way the changes are available for all users.
* Changed format order a little so user has more chances to cancel without any changes committed.
* Added various error-handling and cancel-handling.

### 1.3.0 (12/2020)
* Added choice of filesystem type.
* Figured out proper minimum file size for each filesystem type.

### To-Do / Quirks
* Would be nice to make dialogs wider or narrower in various cases, or control line-breaks in text, but no way to do it.


## Privacy Policy
This software doesn't collect, store, or transmit your identity or personal information or passwords in any way other than handling your LUKS container files as documented.

