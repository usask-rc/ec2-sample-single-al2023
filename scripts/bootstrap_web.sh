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

# This assignment order must match Terraform; see instances.tf
DEVS=("/dev/sdf" "/dev/sdg")
MOUNTS=("/etc/letsencrypt" "/var/www")

# Find root partition and then root device
ROOT_PART=$(findmnt -n -o SOURCE /)
ROOT_DEV="${ROOT_PART%p*}"
echo "Root partition: ${ROOT_PART}" >> /var/log/userdata.log
echo "Root device: ${ROOT_DEV}" >> /var/log/userdata.log

# Loop through all AWS nvme devices except root device
# For each nvme device, create a symlink with the desired mount device name
for NVME in `find /dev | grep -e 'nvme[0-9]\+n1$' | grep -v $ROOT_DEV`
do
  echo "Working on: ${NVME}" >> /var/log/userdata.log
  # get ebs block mapping device path
  SRCDEV=$(/usr/sbin/ebsnvme-id ${NVME} --block-dev)
  echo "Target device: ${SRCDEV}" >> /var/log/userdata.log

  if [ -L ${SRCDEV} ] ; then
    if [ -e ${SRCDEV} ] ; then
        echo "${SRCDEV} is a good link, target is:" >> /var/log/userdata.log
        echo `ls -ld ${SRCDEV}` >> /var/log/userdata.log
    else
        echo "${SRCDEV} is a broken link, removing it now" >> /var/log/userdata.log
        rm -f ${SRCDEV}
        echo "${SRCDEV} is missing, creating a link now" >> /var/log/userdata.log
        ln -s ${NVME} ${SRCDEV}
    fi
  elif [ -e ${SRCDEV} ] ; then
    echo "${SRCDEV} is not a link, cannot touch it" >> /var/log/userdata.log
  else
    echo "${SRCDEV} is missing, creating a link now" >> /var/log/userdata.log
    ln -s ${NVME} ${SRCDEV}
  fi
done

# Relate the device name to the mount point
for index in ${!DEVS[@]}
do
  MDEV=${DEVS[$index]}
  MPATH=${MOUNTS[$index]}
  echo "${MDEV} should be mounted at ${MPATH}" >> /var/log/userdata.log

  if [ -e "$MDEV" ]; then
    # Create the mount point
    if [ ! -d "$MPATH" ]; then
      mkdir -p $MPATH
    fi

    # Do not clobber existing filesystems
    FOUNDFS=$(blkid -o value -s TYPE $MDEV)
    if [ -z "$FOUNDFS" ]; then
      echo "Creating filesystem" >> /var/log/userdata.log
      mkfs.xfs -q $MDEV
    else
      echo "${MDEV} has existing filesystem type: ${FOUNDFS}" >> /var/log/userdata.log
    fi

    # Ensure we can find the block ID for the new device
    BLK_ID=$(blkid $MDEV | cut -f2 -d " ")
    if [[ -z "$BLK_ID" ]]; then
      echo "ERROR: no block ID found for ${MDEV}" >> /var/log/userdata.log
      exit 1
    else
      echo "Block ID found for ${MDEV}: ${BLK_ID}" >> /var/log/userdata.log
    fi

    # Mount the new device by block ID at the mount point
    if ! grep -qF "$BLK_ID" /etc/fstab; then
      echo "Adding mount for block ID ${BLK_ID} to fstab" >> /var/log/userdata.log
      echo "$BLK_ID     $MPATH   xfs    defaults   0   2" | tee --append /etc/fstab >> /var/log/userdata.log
    else
      echo "Mount for block ID ${BLK_ID} is already in fstab" >> /var/log/userdata.log
    fi

    # Clear vars for next loop
    MPATH=""
    MDEV=""
  fi
done

mount -a
