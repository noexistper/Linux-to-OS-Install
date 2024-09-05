# Linux-to-OS-Install
If you are a Linux user and do not have a storage device make a bootable device.
Why not make a small partition in your Laptop/PC Hard disk act as bootable for the new OS to install as Dual Boot?

** It is only tested on Debian Linux and for installing Windows OS.

**Steps**
1. Download OS.iso file.
2. Run the script, It'll check all required packages.
3. Use Gparted to make unallocated space for the NTFS partition.
4. Enter path of NTFS partition.
5. Enter path to .iso file.
6. After restart, choose the partition with bootable OS. Similar to installation from any device.
7. Done

**Others**
In case if you have only one partition and no unallocated space for creating NTFS partition. And you want to resize the current mounted root directory. 
1. If you got LVM, it's easy. I do not have LVM so, you will find methods on discussion websites.
2. steps: for using swap partition, **risky methods**.
3. Run "allocate -l 2G /swapfile"
4.  "chmod 600 /swapfile"
5.  "mkswap /swapfile"
6.  "swapon /swapfile"
7.  "parted /path/to/storage (e.g /dev/nvme0n1)" ** not partition number.
8.  "(parted) resizepart N size" (N is partition number, Size is new size 100gb etc.)
9.  "(parted) quit"
10. "resize2fs /path/to/storage (e.g /dev/nvme0n1)" ** not partition number.
11. "swapoff /swapfile"
12. "rm /swapfile"
