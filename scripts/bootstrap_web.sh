#!/bin/bash

# This script augments terraform so that EBS volumes
# are formatted and mounted on first boot, and fstab
# is updated for future boot. 
#
# This script is for Amazon Linux 2023.

sudo dnf update -y

echo "----------- BOOT ------------" >> /var/log/userdata.log
echo `date` >> /var/log/userdata.log

# Wait for EBS volumes to be attached
sleep 10

# This assignment order must match Terraform; see instances.tf
DEVS=("/dev/sdf" "/dev/sdg")
MOUNTS=("/etc/letsencrypt" "/var/www")

# Find root partition and then root device
ROOT_PART=$(findmnt -n -o SOURCE /)
ROOT_DEV="${ROOT_PART%p*}"
echo "Root partition: ${ROOT_PART}" >> /var/log/userdata.log
echo "Root device: ${ROOT_DEV}" >> /var/log/userdata.log

# Loop through all AWS named devices except root device
for NVME in `find /dev | grep -e 'nvme[0-9]\+n1$' | grep -v $ROOT_DEV`
do
    echo "Working on: ${NVME}" >> /var/log/userdata.log
    # get ebs block mapping device path
    OLD=$(/usr/sbin/ebsnvme-id ${NVME} --block-dev)
    echo "Target device: ${OLD}" >> /var/log/userdata.log

    # Relate the old device name to the mount point
    for index in ${!DEVS[@]}; do
      if [ "${DEVS[$index]}" = "$OLD" ]; then
        MPATH=${MOUNTS[$index]}
      fi
    done
    if [ -z "$MPATH" ]; then
      echo "ERROR: no mount path defined for ${OLD} in bootstrap script" >> /var/log/userdata.log
      exit 1
    else
      echo "Mount path: ${MPATH}" >> /var/log/userdata.log
    fi

    # Create the mount point
    if [ ! -d "$MPATH" ]; then
      mkdir -p $MPATH
    fi

    # Do not clobber existing xfs filesystems
    FOUNDFS=$(blkid -o value -s TYPE $NVME)
    if [ -z "$FOUNDFS" ]; then
      echo "Creating filesystem" >> /var/log/userdata.log
      mkfs.xfs -q $NVME
    else
      echo "${NVME} has existing filesystem type: ${FOUNDFS}" >> /var/log/userdata.log
    fi

    # Ensure we can find the block ID for the new device
    BLK_ID=$(blkid $NVME | cut -f2 -d " ")
    if [[ -z "$BLK_ID" ]]; then
      echo "ERROR: no block ID found for ${NVME}" >> /var/log/userdata.log
      exit 1
    else
      echo "Block ID found for ${NVME}: ${BLK_ID}" >> /var/log/userdata.log
    fi

    # Mount the new device by block ID at the mount point
    if ! grep -qF "$BLK_ID" /etc/fstab; then
      echo "Adding mount for block ID ${BLK_ID} to fstab" >> /var/log/userdata.log
      echo "$BLK_ID     $MPATH   xfs    defaults   0   2" | tee --append /etc/fstab
    else
      echo "Mount for block ID ${BLK_ID} is already in fstab" >> /var/log/userdata.log
    fi

    # Clear MPATH for next loop
    MPATH=""

done

mount -a

