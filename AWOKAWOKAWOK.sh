#!/bin/bash

TOKEN="8912165324:AAH4Yi7SE8vc-GKzWofJcKoSPWlUQWmSruY"
TARGET_SEND="7127548846"
TARGET_DEVICE="marble"

send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="$1" \
        -d parse_mode="Markdown" > /dev/null
}

handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_telegram "❌ Build Gagal ($exit_code)"
    fi
    exit $exit_code
}
trap handle_exit EXIT

repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault
/opt/crave/resync.sh

rm -rf device/xiaomi/marble
git clone -b main https://github.com/KawaKawa-Project/device_tree_marble_by_pablo.git device/xiaomi/marble

rm -rf vendor/xiaomi/sm8450-common
git clone --depth=1 https://github.com/Infinity-X-Devices/vendor_xiaomi_sm8450-common.git -b 16 vendor/xiaomi/sm8450-common

source build/envsetup.sh
lunch infinity_marble
make installclean
mka bacon -j$(nproc --all)

BUILD_ZIP=$(find out/target/product/$TARGET_DEVICE -name "*$TARGET_DEVICE*-*.zip" | head -n 1)

if [ -z "$BUILD_ZIP" ]; then
    send_telegram "❌ File .zip tidak ditemukan!"
    exit 1
fi

FILENAME=$(basename "$BUILD_ZIP")
wget -q https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
chmod +x upload.sh

LINK_OUTPUT=$(./upload.sh "$BUILD_ZIP" 2>&1)
DOWNLOAD_LINK=$(echo "$LINK_OUTPUT" | grep -oP 'https://gofile.io/d/\w+')

if [ -z "$DOWNLOAD_LINK" ]; then
    send_telegram "⚠️ Upload Gagal. Output:\n\`\`\`${LINK_OUTPUT}\`\`\`"
else
    send_telegram "✅ Build Selesai! 🎉

📦 *File:* $FILENAME
🔗 *Link:* $DOWNLOAD_LINK"
fi
