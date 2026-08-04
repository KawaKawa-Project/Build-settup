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
Crave pull out/target/product/*/*zip
cd marble
wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
chmod +x upload.sh
TELEGRAM_TOKEN="18912165324:AAFkT_freQE2COyn5jhjfk-rmdjkBGRnL80"
CHAT_ID="@archivenyamasagung"
GOFILE_LINK=$(./upload.sh *.zip* | grep -oE 'https://gofile\.io/d/[a-zA-Z0-9]+' | head -n 1)
if [ -n "$GOFILE_LINK" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=New Build Rom By @SkuyyyLaahhh: ${GOFILE_LINK}"
fi
rm *.zip*
