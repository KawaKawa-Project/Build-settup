#!/bin/bash

# Load credentials from environment variables (Recommended)
# Jika dijalankan di Crave, pastikan variabel ini diset di Secrets/Env Vars
TOKEN=8912165324:AAH4Yi7SE8vc-GKzWofJcKoSPWlUQWmSruY
TARGET_SEND=7127548846

if [ -z "$TOKEN" ] || [ -z "$TARGET_SEND" ]; then
    echo "Error: Token or Chat ID missing."
    exit 1
fi

TARGET_DEVICE="marble"
ROM_NAME="Infinity-X-KawaKawa"

send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="$1" \
        -d parse_mode="Markdown" > /dev/null
}

handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_telegram "❌ Build $ROM_NAME Gagal ($exit_code)"
    else
        send_telegram "✅ Build $ROM_NAME Selesai!"
    fi
    exit $exit_code
}

trap handle_exit EXIT

send_telegram "🚀 Memulai Build $ROM_NAME..."

# 1. Initialize Repo ProjectInfinity-X
send_telegram "📥 Initializing repo..."
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# 2. Sync Source (Initial Sync to get the base structure)
send_telegram "🔄 Initial sync..."
/opt/crave/resync.sh

# 3. REMOVE Default Device Tree for Marble (PENTING!)
# Kita hapus folder bawaan agar bisa diganti dengan repo kita sendiri
send_telegram "🗑️ Removing default device tree for marble..."
rm -rf device/xiaomi/marble

# 4. Clone Your Custom Device Tree
send_telegram "📂 Cloning KawaKawa device tree..."
git clone -b main https://github.com/KawaKawa-Project/device_tree_marble_by_pablo.git device/xiaomi/marble

# 5. Update Vendor (Optional, jika vendor bawaan Infinity-X bermasalah)
# Vendor sm8450-common biasanya kompatibel karena marble pakai chipset itu.
send_telegram "📦 Updating vendor sm8450-common..."
rm -rf vendor/xiaomi/sm8450-common
git clone --depth=1 https://github.com/Infinity-X-Devices/vendor_xiaomi_sm8450-common.git -b 16 vendor/xiaomi/sm8450-common

# 6. Setup Build Environment
send_telegram "🔧 Setting up environment..."
source build/envsetup.sh

# 7. Lunch Target
# Pastikan nama lunch target sesuai dengan yang ada di device tree kamu (cek di .mk)
LUNCH_TARGET="infinity_marble-user"
send_telegram "🍽️ Lancing $LUNCH_TARGET..."
lunch $LUNCH_TARGET

# 8. Clean Intermediate Files
send_telegram "🧹 Running installclean..."
make installclean

# 9. Start Build
send_telegram "🔨 Compiling... (This will take a while)"
mka bacon -j$(nproc --all)

send_telegram "✨ Build finished! uploading to GoFile..."

# Cek apakah file zip ada
BUILD_ZIP=$(find out/target/product/$TARGET_DEVICE -name "*$TARGET_DEVICE*-*.zip" | head -n 1)

if [ -z "$BUILD_ZIP" ]; then
    send_telegram "❌ File .zip not found!"
    exit 1
fi

FILENAME=$(basename "$BUILD_ZIP")
send_telegram "📤 Uploading $FILENAME..."

# Download script upload lordgaruda
wget -q https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
chmod +x upload.sh

# Jalankan upload dan SIMPAN outputnya ke variabel LINK_OUTPUT
# Script lordgaruda biasanya mencetak link di baris terakhir atau stdout
LINK_OUTPUT=$(./upload.sh "$BUILD_ZIP" 2>&1)

# Coba ekstrak link http dari output tersebut menggunakan grep
DOWNLOAD_LINK=$(echo "$LINK_OUTPUT" | grep -oP 'https://gofile.io/d/\w+')

if [ -z "$DOWNLOAD_LINK" ]; then
    # Jika gagal ekstrak, kirim seluruh output sebagai debug
    send_telegram "⚠️ Output: \n\`\`\`${LINK_OUTPUT}\`\`\`"
else
    send_telegram "✅ Upload Succesfuly! 🎉

📦 *File:* $FILENAME
🔗 *Link Download:* $DOWNLOAD_LINK

_Silakan dicoba!_"
fi
