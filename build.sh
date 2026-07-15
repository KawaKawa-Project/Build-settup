#!/bin/bash

# Load credentials from environment variables
TOKEN="${TOKEN_TELE:-${TOKEN:-}}"
TARGET_SEND="${TARGET_SEND:-}"

# Validate required credentials
if [ -z "$TOKEN" ] || [ -z "$TARGET_SEND" ]; then
    exit 1
fi

TARGET_DEVICE="marble"
ROM_NAME="Infinity-X"

# Java settings (sesuaikan dengan resource Crave)
export _JAVA_OPTIONS="-Xmx2g -Xms512m"
export ANDROID_JACK_VM_ARGS="-Xmx2g"

send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="$1" \
        -d parse_mode="Markdown" > /dev/null
}

handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_telegram "❌ Build $ROM_NAME Gagal dengan kode error: $exit_code"
    else
        send_telegram "✅ Build $ROM_NAME Selesai! Silakan cek hasil build."
    fi
    exit $exit_code
}

trap handle_exit EXIT

# Start notification
send_telegram "🚀 Memulai Build $ROM_NAME untuk $TARGET_DEVICE..."

# Clean previous manifests ONLY (AMAN sesuai rules)
rm -rf .repo/local_manifests

# Initialize repo
send_telegram "📥 Initializing repo..."
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16

# Clone local manifest
send_telegram "📂 Cloning local manifest..."
git clone -b main https://github.com/KawaKawa-Project/local_manifest.git .repo/local_manifests

# Sync sources - WAJIB pakai resync.sh Crave!
send_telegram "🔄 Syncing sources... (Proses ini memakan waktu)"
/opt/crave/resync.sh

# Setup build environment
send_telegram "🔧 Setting up build environment..."
source build/envsetup.sh

# Lunch target
LUNCH_TARGET="infinity_${TARGET_DEVICE}-user"
send_telegram "🍽️ Mencoba lunch target: $LUNCH_TARGET"

if ! lunch "$LUNCH_TARGET" &>/dev/null; then
    send_telegram "⚠️ Target utama tidak ditemukan, mencari alternatif..."
    AVAILABLE=$(lunch 2>&1 | grep -i "$TARGET_DEVICE" | head -1 | awk '{print $2}' | tr -d '.')
    if [ -n "$AVAILABLE" ]; then
        send_telegram "✅ Menggunakan target alternatif: $AVAILABLE"
        lunch "$AVAILABLE"
    else
        send_telegram "❌ Lunch gagal: Device $TARGET_DEVICE tidak ditemukan di daftar."
        exit 1
    fi
else
    send_telegram "✅ Lunch target berhasil diset."
fi

# Clean intermediate files - WAJIB pakai installclean (bukan rm -rf out/)
send_telegram "🧹 Running installclean..."
make installclean

# Build ROM
send_telegram "🔨 Memulai kompilasi (mka bacon)... Mohon tunggu."
mka bacon -j$(nproc --all)

# Jika sampai sini berarti sukses (karena trap handle_exit akan menangani jika gagal)
send_telegram "✨ Proses build selesai!"

# pull out hasil build di /infi/marble
crave pull out/target/product/*/*zip
send_telegram "hasil build ada di /marble silahkan cek"
