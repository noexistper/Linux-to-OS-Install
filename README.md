# Linux-to-OS-Install
If you are a Linux user and do not have a storage device make a bootable device.
Why not make a small partition in your Laptop/PC Hard disk act as bootable for the new OS to install as Dual Boot?

** It is only tested on Debian Linux and for installing Windows OS.

**Steps**
1. Download OS.iso file.
2. Run the script, It'll check all required packages.
3. Use Gparted to make unallocated space for the NTFS partition.
4. Enter path of NTFS partition.
5. Enter path of mount point, don't worry it'll create folder if not available.
6. Enter path to .iso file.
7. After restart, choose the partion with bootable OS. Similar to installation from any device.
8. Done. 
