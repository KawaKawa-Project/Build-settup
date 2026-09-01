#!/bin/bash

#Clean
rm -rf .repo/local_manifests
rm -rf kernel/xiaomi/sm8450
rm -rf device/xiaomi/marble

# Initial ROM source
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --depth=1 --no-repo-verify --git-lfs -g default,-mips,-darwin,-notdefault

# add local manifest
git clone https://github.com/KawaKawa-Project/local_manifest.git -b infinity-x_local_manifest .repo/local_manifests

# Sync ROM
/opt/crave/resync.sh

# Start the build ROM
. build/envsetup.sh

# lunch & build
lunch infinity_marble-userdebug
make installclean
m bacon
