#!/bin/bash

TOKEN_BOT="8912165324:AAH3r8qs7Mtl1N7_z3W5msuoiyRIZVNfgyg"
TARGET_SEND="@archivenyamasagung"

START_MSG="New Plan Build Lunaris AOSP%0AMaintainer @SkuyyyLaahhh"
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

# 5. pull out build zip
crave pull out/target/product/*/*.zip
cd marble
ZIP_NAME=$(ls *.zip | head -n 1)

if [ -f "$ZIP_NAME" ]; then
    # Github script gofile uploader
    wget -qO upload.sh https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh

    # upload to gofile
    UPLOAD_OUTPUT=$(./upload.sh "$ZIP_NAME")
    LINK=$(echo "$UPLOAD_OUTPUT" | grep -Eo 'https://gofile.io/d/[a-zA-Z0-9]+' | head -n 1)

    rm *.zip

    if [ -z "$LINK" ]; then
        LINK="link not detected"
    fi

    # Bot Telegram
    SUCCESS_MSG="New Build Rom By @SkuyyyLaahhh%0A${ZIP_NAME}%0ALink : ${LINK}"
    curl -s -X POST "https://api.telegram.org/bot${TOKEN_BOT}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="${SUCCESS_MSG}"
fi
