
#!/bin/bash

#Clean
rm -rf .repo/local_manifests

# 1. Initial ROM source
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# 1,5 add local manifest
git clone https://github.com/KawaKawa-Project/local_manifest.git -b infinity-x_local_manifest .repo/local_manifests

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Start the build ROM
. build/envsetup.sh

# 4. lunch & build
lunch infinity_marble-userdebug
m bacon
