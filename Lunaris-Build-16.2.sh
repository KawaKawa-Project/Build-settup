#!/bin/bash

TOKEN_BOT="8912165324:AAFdrzRlTInk5QB49EI3Oo9hBn7LKc-sGtQ"
TARGET_SEND="@kawabuildsupport"

START_MSG="
New Plan Build Marble, Lunaris AOSP
Maintainer @SkuyyyLaahhh
Adding
Powerhint, MGLRU on kernel"
curl -s -X POST "https://api.telegram.org/bot${TOKEN_BOT}/sendMessage" \
    -d chat_id="${TARGET_SEND}" \
    -d text="${START_MSG}"

# Clean
rm -rf .repo/local_manifests

# 1. Initial ROM source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs --depth=1

# 1.5 add local manifest
git clone https://github.com/KawaKawa-Project/local_manifest.git -b Lunaris_local_manifest .repo/local_manifests

# 2. Sync ROM
/opt/crave/resync.sh

# 3. Start the build ROM
. build/envsetup.sh

# 4. lunch & build
lunch lineage_marble-bp4a-userdebug
m bacon
