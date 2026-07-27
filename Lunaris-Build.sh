#!/bin/bash

#Clean
rm -rf .repo/local_manifests

# 1. Initial ROM source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs --depth=1

# 1,5 add local manifest
git clone https://github.com/KawaKawa-Project/local_manifest.git -b Lunaris_local_manifest .repo/local_manifests

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Start the build ROM
. build/envsetup.sh

# 4. lunch
lunch lineage_marble-bp4a-userdebug
m bacon

# 5. upload to gofile
crave pull out/target/product/*/*zip
cd marble # marble = your phone code name 
wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
chmod +x upload.sh
./upload.sh *.zip*
rm *.zip*
