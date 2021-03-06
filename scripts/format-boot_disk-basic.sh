#!/usr/bin/env bash

# Error Handling
set -euo pipefail

# Get Desired Installation Disk (Whole Disk wille be destroyed and then used!!!!)
echo; echo; echo
lsblk -dplx size -o name,size,type,mountpoint | grep -Ev "boot|rpmb|loop"
echo; echo "Please Select The Hardrive to Install To!"
select device in $(lsblk -dplnx size -o name | grep -Ev "boot|rpmb|loop"); do
	# leave the loop if the user says 'stop'
	if [[ "$REPLY" == stop ]]; then 
			exit 1 
	fi

	# complain if no file was selected, and loop to ask again
	if [[ "$device" == "" ]]; then
			echo "'$REPLY' is not a valid number" 
			continue
	fi

	# now we can return the selected folder
	echo "$device"
	break
done

# Calculate Swap Size
swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
swap_end="$(( $swap_size + 954 + 1 ))MiB"

# Partition Drive (Keeps Nothing!!)
printf "Paritioning Hard Drive!\n"
parted --script "${device}" \
        mklabel gpt \
        mkpart ESP fat32 1MiB 954MiB name 1 boot set 1 esp on \
        mkpart primary linux-swap 954MiB "${swap_end}" name 2 swap \
        mkpart primary ext4 "${swap_end}" 100% name 3 nixos

# Simple globbing was not enough as on one device I needed to match /dev/mmcblk0p1 
# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other devices.
part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_swap="$(ls ${device}* | grep -E "^${device}p?2$")"
part_root="$(ls ${device}* | grep -E "^${device}p?3$")"

# Clean Partitions
printf "Cleaning Partitions!\n"
wipefs --all --force "${part_boot}"
wipefs --all --force "${part_swap}"
wipefs --all --force "${part_root}"

# Format Partitions
printf "Formatting Partitions!\n"
mkfs.vfat -F 32 -n boot "${part_boot}"
mkswap -L swap "${part_swap}"
mkfs.ext4 -F -L nixos "${part_root}"

# Pause To Prevent Errors In Mounting
sleep 5s

# Mount Partitions
printf "Mounting Partitions!\n"
mount /dev/disk/by-label/nixos /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Enable swap for installer
swapon /dev/disk/by-label/swap