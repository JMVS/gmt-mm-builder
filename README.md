# ISO & Magisk Module Builder for Genymobile Tools
This program downloads, extracts, injects and creates the ISO file required for the Magisk Module Genymobile Tools. Then, builds and packages Magisk Module Genymobile Tools for install as a Magisk Module.
Currently only supports Windows platforms.

## Pre-requisites
* OnePlus 3T phone.
* Internet connection on the computer.
* Available space on disk to build ISO and Magisk Module (approx. ~50-60 MiB).
* Makisk Manager installed on phone.
* USB Drivers installed on the computer.
* ADB Debugging enabled on phone.
* Computer authorized to make use of USB ADB Debugging.

## How to use it
1. [Download program](https://github.com/JMVS/gmt-mm-builder/archive/master.zip "ISO & Magisk Module Builder for Genymobile Tools").
2. Extract archive to a **writable** folder.
3. Run **"buildgmtiso.cmd"** and wait it to finish.
4. If everything went OK, you should see a **"gmt-mm.zip"** file.
5. Copy **"gmt-mm.zip"** to your phone.
6. Install as a Magisk Module.

### Additional options
* You can place original usb_drivers.iso file from your phone inside folder original_iso to skip extracting it from your phone.
* If you choose to extract usb_drivers.iso file from your phone, you should already have USB drivers installed, ADB debugging on and computer authorized, otherwise pulling file will fail.

### Caveats
* Once properly installed as a Magisk Module, when connected to a computer, you should select Transfer Files option for Windows to show the ISO as a drive.

## Troubleshooting
Error codes displayed by buildgmtiso.cmd:
1. Error downloading scrcpy x32 version from server: Check Internet connection / Check folder is writable / Check available space / Server might be down (try again later)
2. Error downloading scrcpy x64 version from server: Check Internet connection / Check folder is writable / Check available space / Server might be down (try again later)
3. Error downloading gnirehtet x64 version from server:Check Internet connection / Check folder is writable / Check available space / Server might be down (try again later)
4. Error downloading ADB from server: Check Internet connection / Check folder is writable / Check available space / Server might be down (try again later)
5. Error updating scrcpy x32 version archive: Check folder is writable / Check available space / Folder/files might already exists (delete manually)
6. Error updating scrcpy x64 version archive: Check folder is writable / Check available space / Folder/files might already exists (delete manually)
7. Error updating gnirehtet x64 version archive: Check folder is writable / Check available space / Folder/files might already exists (delete manually)
8. Error updating ADB archive: Check folder is writable / Check available space / Folder/files might already exists (delete manually)
9. Invalid option selected: Select a valid option
10. Error extracting ADB files: Check folder is writable / Check available space / Folder/files might already exists/running (delete manually)
11. Error extracting original ISO files: Check folder is writable / Check available space / Check provided ISO is valid
12. Error building modified ISO: Check folder is writable / Check available space

## Credits
[scrcpy](https://github.com/Genymobile/scrcpy "scrcpy GitHub repo") by Romain Vimont Copyright (C) 2018 Genymobile
[gnirehtet](https://github.com/Genymobile/gnirehtet "gnirehtet GitHub repo") by Romain Vimont Copyright (C) 2018 Genymobile
adb by Google
