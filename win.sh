#!/bin/bash

# FUNCTIONS
print_message() {
    echo -e "\n\033[1;34m$1\033[0m\n"
}
# .............................................................................................
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root."
        exit 1
    fi
}
# .............................................................................................
check_and_install_dependencies() {
    local packages=("mount" "cp" "parted" "grub-mkconfig" "update-grub" "gparted")
    local missing_packages=()

    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done

    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "The following required packages are missing: ${missing_packages[*]}"
        while true; do
            read -p "Do you want to install them? [y/n]: " install_choice
            if [ "$install_choice" = "y" ]; then
                for pkg in "${missing_packages[@]}"; do
                    apt-get install -y "$pkg"
                    if [ $? -ne 0 ]; then
                        echo "Error: Failed to install $pkg."
                        exit 1
                    fi
                done
                break
            elif [ "$install_choice" = "n" ]; then
                echo "Please install the required packages and rerun the script."
                exit 1
            else
                echo "Invalid input. Please enter y or n."
            fi
        done
    fi
}
# .............................................................................................
list_partitions() {
    echo "Available partitions:"
    lsblk -f | grep -v "loop" | grep -v "sr0" 
    echo
}
# .............................................................................................
# .............................................................................................
check_root
check_and_install_dependencies
list_partitions
# .............................................................................................
# .............................................................................................

while true; do
    read -p "Have you already created an NTFS partition? Enter Y for Yes, N for No: " partition_created
    if [[ "$partition_created" == "Y" || "$partition_created" == "y" ]]; then
        break
    elif [[ "$partition_created" == "N" || "$partition_created" == "n" ]]; then
        print_message "Opening GParted for partition creation..."
        gparted &
        read -p "Press [Enter] once you have created the partition and want to continue..."
        break
    else
        echo "Invalid input. Please enter Y or N."
    fi
done
# .............................................................................................
# .............................................................................................
list_partitions
echo "................................................."


read -p "Enter the partition (e.g., /dev/nvme0n1p3): " target_partition
if lsblk | grep -q "$target_partition"; then
    break
else
    echo "Invalid partition. Please enter a valid partition from the list above."
fi
# .............................................................................................
# .............................................................................................
while true; do
    read -p "Enter the path to the Windows ISO file: " iso_location
    if [ -f "$iso_location" ]; then
        iso_name=$(basename "$iso_location")
        break
    else
        echo "Error: ISO file not found at $iso_location. Please enter a valid path."
    fi
done

# .............................................................................................
# .............................................................................................
print_message "Mounting the NTFS partition..."
mount "$target_partition" "$mount_point"
if [ $? -eq 0 ]; then
    break
else
    echo "Error: Failed to mount $target_partition. Please ensure the partition exists and is formatted as NTFS."
    list_partitions
fi
# .............................................................................................

iso_mount_point="/mnt/win11_iso"

mkdir -p "$iso_mount_point"

mount -o loop "$iso_location" "$iso_mount_point"
if [ $? -eq 0 ]; then
    break
else
    echo "Error: Failed to mount $iso_location. Please check the ISO file and try again."
fi

# .............................................................................................
print_message "Copying $iso_name files to the NTFS partition..."
cp -r "$iso_mount_point"/* "$mount_point"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files to $mount_point."
    exit 1
fi

# .............................................................................................
umount "$iso_mount_point"
umount "$mount_point"

# .............................................................................................
print_message "Updating GRUB configuration..."
update-grub
if [ $? -ne 0 ]; then
    echo "Error: Failed to update GRUB."
    exit 1
fi

# .............................................................................................
print_message "The $iso_name files have been copied successfully."

echo -e "\033[1;32mInstructions:\033[0m"
echo "** After your computer restarts, boot from the partition you copied the $iso_name files to."

echo -e "\nYour PC will restart in 60 seconds."
read -p "Press [Enter] to restart immediately, or wait for 60 seconds..."
shutdown -r +1 "Press Ctrl+C to cancel."
shutdown -r now
