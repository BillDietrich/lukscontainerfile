# README for "lukscontainerfile" Dolphin Service Menu

This is a "Service Menu" extension for KDE's Dolphin file manager, to handle LUKS-encrypted container files.

Dolphin has native features to handle LUKS-encrypted volumes (disks, partitions), but not to handle LUKS-encrypted container files.

This extension creates LUKS2 container files with Btrfs filesystem inside, and mounts/unmounts LUKS container files. The mount/unmount should work regardless of the container's LUKS version or type of filesystem inside.  So you could create a LUKS container file manually if you wished, and still use the mount/unmount actions of this extension.

You must have "sudo" permission to use this extension.

This software works on Linux only, not any other platform where Dolphin runs.

Created 2020 by Bill Dietrich ([bill@billdietrich.me](bill@billdietrich.me), [https://www.billdietrich.me](https://www.billdietrich.me))

Source code is at [https://github.com/BillDietrich/lukscontainerfile](https://github.com/BillDietrich/lukscontainerfile)


## Pre-Installation

You must have Dolphin file manager and X desktop utilities and Btrfs:

```
dolphin --version
xdg-mime --version
btrfs --version			# if this fails, install "btrfs-progs"
```


## Install

```
# copy the files to your disk, then:
chmod +x install.sh
./install.sh
```

If you want to test that the file extension "luks" has been associated with the correct MIME type:

```
touch TEST.luks

xdg-mime query filetype TEST.luks
# should see "application/luks"

#file --mime-type TEST.luks
# should see "application/octet"

rm TEST.luks
```


## Un-install

```
cd ~/.local/share/kservices5/ServiceMenus
./lukscontainerfile-uninstall.sh
```


## Use

In Dolphin file manager, right-click on a NAME.luks file, and the context menu will include menu items "Format LUKS2 container file", "Mount LUKS container file", and "Unmount LUKS container file".

All operations require you to have "sudo" permission.

To use the context menu items:

* Format LUKS2 container file

    Create a file named SOMENAME.luks, with no contents or any contents.  In CLI, you could do "touch TEST.luks".  In Dolphin file manager, you could do "Create new text file", name it "TEST", then rename it to "TEST.luks".
    
	Right-click on the .luks file you created, and select the "Format LUKS2 container file" menu item.  Follow the dialogs, giving information and passwords as needed.  The file will be formatted as a LUKS2 container with a Btrfs filesystem (mixed mode) inside, a header backup file called TEST.luks.HeaderBackup will be created, and a mount-point /mnt/TEST will be created.

	Security note: As the container is being LUKS-formatted, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Note: You are free to delete the header backup file if you wish.  But it is a good idea instead to save it somewhere safe.  If the header of the container file gets damaged, you may be able to use the header backup file to repair it.

	Note: Every time you format a container file, a mount-point such as /mnt/TEST will be created for it.  But when you delete a container file, the mount-point is not deleted.  This could lead to clutter in /mnt.  You could delete the old mount-points (they're just directories) manually, for the ones that correspond to container files you've deleted.

* Mount LUKS container file

	Right-click on the .luks file you created, select the "Mount LUKS container file" menu item, give the required passwords, and the existing TEST.luks container file will be mounted (with added flag noatime) on mount-point /mnt/TEST.

	Security note: As the container is being LUKS-opened, very briefly the container's password is stored in a temporary file.  Normal precautions are taken to keep it secure, but for example the file is deleted the standard way, not with any secure-delete facility.

	Security note: The mount-point for the container is owned by current user and has 700 permissions (usable only by current user) when mounted.  If you want to change this, you can edit the files lukscontainerfile-format.sh and lukscontainerfile-mount.sh in ~/.local/share/kservices5/ServiceMenus

* Unmount LUKS container file

	Right-click on the .luks file you created, select the "Unmount LUKS container file" menu item, give the required password, and the existing TEST.luks container file will be unmounted from mount-point /mnt/TEST.


## Status

### 1.0.0 (12/2020)
* Tested only on Kubuntu 20.10 with Dolphin 20.08.2.

### 1.1.0 (12/2020)
* Tweaked README.
* New icon for extension and format action.
* Fixed icon-setting in MIME database.

### To-Do / Quirks
* Mkfs hangs if less than 109 MB, but I'm using --mixed, why ?
* More graceful way to create container file ?  Put in New sub-menu ?  Combine new and format into one menu item "new" ?
* Better error-handling.
* I think ~/.local/share/kservices5/ServiceMenus is not the only place where Service Menus can be stored.  Maybe just always using that place is good enough ?


## Privacy Policy
This software doesn't collect, store, or transmit your identity or personal information or passwords in any way other than handling your LUKS container files as documented.

