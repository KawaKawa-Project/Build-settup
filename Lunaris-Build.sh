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

# 4. lunch & build
TELEGRAM_TOKEN="18912165324:AAFkT_freQE2COyn5jhjfk-rmdjkBGRnL80"
CHAT_ID="@archivenyamasagung"

lunch lineage_marble-bp4a-userdebug
m bacon

# Cek apakah proses build (m bacon) berhasil atau gagal
if [ $? -ne 0 ]; then
    echo "Build gagal! Mengirim notifikasi ke Telegram..."
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=❌ Build ROM Failed for @SkuyyyLaahhh! Please check build logs."
    exit 1
fi

# 5. upload to gofile
Crave pull out/target/product/*/*zip
cd marble || exit 1

wget -q https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
chmod +x upload.sh

GOFILE_LINK=$(./upload.sh *.zip* | grep -oE 'https://gofile\.io/d/[a-zA-Z0-9]+' | head -n 1)

if [ -n "$GOFILE_LINK" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=✅ New Build Rom By @SkuyyyLaahhh: ${GOFILE_LINK}"
else
    # Jika build sukses tapi file zip tidak ditemukan / gagal upload
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=⚠️ Build Succeeded, but failed to upload or zip file not found."
fi

rm -f *.zip*
