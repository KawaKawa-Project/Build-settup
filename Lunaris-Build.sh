#!/bin/bash

# 1. Initial ROM source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs

# 1,5 add local manifest
mkdir -p .repo/local_manifests
curl -s https://raw.githubusercontent.com/KawaKawa-Project/Build-settup/refs/heads/Lunaris-16.2/Lunaris_local_manifest.xml -o .repo/local_manifests/marble.xml

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Start the build ROM
. build/envsetup.sh

# lunch
lunch lineage_marble-bp4a-userdebug
m bacon

# 4. Upload to Gofile 
if [ -f out/target/product/marble/*202607*.zip ]; then
  wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
  chmod +x upload.sh ; ./upload.sh out/target/product/marble/*202607*.zip
else
  echo "zip not found out/target/product/marble/"
fi
