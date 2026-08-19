#!/bin/bash

#Clean
rm -rf .repo/local_manifests
rm -rf kernel/xiaomi/marble
rm -rf device/xiaomi/marble

# 1. Initial ROM source
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# 1,5 add local manifest
git clone https://github.com/KawaKawa-Project/local_manifest.git -b infinity-x_local_manifest .repo/local_manifests

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Add Root Resukisu
cd kernel/xiaomi/marble
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
cd ../../../..

# 4. Start the build ROM
. build/envsetup.sh

# 5. lunch & build
lunch infinity_marble-userdebug
make installclean
m bacon
