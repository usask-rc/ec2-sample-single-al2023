#!/bin/bash

# This script augments terraform so that EBS volumes
# are formatted and mounted on first boot, and fstab
# is updated for future boot. 
#
# This script is for Amazon Linux 2023.

sudo dnf update -y

# Wait for EBS volumes to be attached
sleep 10

# This assignment order must match Terraform; see instances.tf
DEVS=("/dev/sdf" "/dev/sdg")
MOUNTS=("/etc/letsencrypt" "/var/www")

# Find root partition and then root device
ROOT_PART=$(findmnt -n -o SOURCE /)
ROOT_DEV="${ROOT_PART%p*}"

# Loop through all AWS named devices except root device
for NVME in `find /dev | grep -e 'nvme[0-9]\+n1$' | grep -v $ROOT_DEV`
do
    # get ebs block mapping device path
    OLD=$(/usr/sbin/ebsnvme-id ${NVME} --block-dev)

    # Relate the old device name to the mount point
    for index in ${!DEVS[@]}; do
      if [ "${DEVS[$index]}" = "$OLD" ]; then
        MPATH=${MOUNTS[$index]}
      fi
    done
    if [ -z "$MPATH" ]; then
      echo "ERROR: no mount path defined for ${OLD} in bootstrap script"
      exit 1
    fi

    # Create the mount point
    if [ ! -d "$MPATH" ]; then
      mkdir -p $MPATH
    fi

    # Do not clobber existing xfs filesystems
    FOUNDFS=$(blkid -o value -s TYPE $NVME)
    if [ -z "$FOUNDFS" ]; then
      mkfs.xfs -q $NVME
    else
      echo "$NVME has existing filesystem type: $FOUNDFS"
    fi

    # Ensure we can find the block ID for the new device
    BLK_ID=$(blkid $NVME | cut -f2 -d " ")
    if [[ -z "$BLK_ID" ]]; then
      echo "ERROR: no block ID found for $NVME"
      exit 1
    fi

    # Mount the new device by block ID at the mount point
    if ! grep -qF "$BLK_ID" /etc/fstab; then
      echo "$BLK_ID     $MPATH   xfs    defaults   0   2" | tee --append /etc/fstab
    fi

    # Clear MPATH for next loop
    MPATH=""

done

mount -a

