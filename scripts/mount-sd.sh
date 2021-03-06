#!/bin/bash

# The only case where this script would fail is:
# mkfs.vfat /dev/mmcblk1 then repartitioning to create an empty ext2 partition

DEF_UID=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEF_GID=$(grep "^GID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=$(getent passwd $DEF_UID | sed 's/:.*//')
MNT=/media/sdcard
MOUNT_OPTS="dirsync,noatime,users"
if [ -z "${ACTION}" ] || [ -z "${DEVNAME}" ] || [ -z "${ID_FS_UUID}" ] || [ -z "${ID_FS_TYPE}" ]; then
	exit 1
fi

if [ "$ACTION" = "add" ]; then
    mkdir -p $MNT/${ID_FS_UUID}
    chown $DEF_UID:$DEF_GID $MNT $MNT/${ID_FS_UUID}

    case "${ID_FS_TYPE}" in
	vfat|exfat)
	    mount ${DEVNAME} $MNT/${ID_FS_UUID} -o uid=$DEF_UID,gid=$DEF_GID,$MOUNT_OPTS,utf8,flush,discard || /bin/rmdir $MNT/${ID_FS_UUID}
	    ;;
	# NTFS support has not been tested but it's being left to please the ego of an engineer!
	ntfs)
	    mount ${DEVNAME} $MNT/${ID_FS_UUID} -o uid=$DEF_UID,gid=$DEF_GID,$MOUNT_OPTS,utf8 || /bin/rmdir $MNT/${ID_FS_UUID}
	    ;;
	*)
	    mount ${DEVNAME} $MNT/${ID_FS_UUID} -o $MOUNT_OPTS || /bin/rmdir $MNT/${ID_FS_UUID}
	    ;;
    esac
else
    DIR=$(mount | grep -w ${DEVNAME} | cut -d \  -f 3)
    umount $DIR || umount -l $DIR
fi
