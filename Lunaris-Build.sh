#!/bin/bash

# 1. Initial ROM source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs

# 1,5 add local manifest
rm -rf .repo/local_manifests
rm -rf device/xiaomi/marble
git clone https://github.com/KawaKawa-Project/local_manifest.git -b Lunaris_local_manifest .repo/local_manifests

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Start the build ROM
. build/envsetup.sh

# lunch
lunch lineage_marble-bp4a-userdebug
m bacon
