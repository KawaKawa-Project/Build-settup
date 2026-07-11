#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8912165324:AAFzwMIB-kea9ICh5l3XKbd4E-6To2Dou9w"
TARGET_SEND="7127548846"

# --- KONFIGURASI BUILD ---
MAINTAINER_NAME="OKawaKawa"
WITH_GAPPS=false
TARGET_DEVICE="marble"
BUILD_DIR="BUILD"
TARGET_RELEASE="ap4" # Codename Android 16 (VanillaIceCream) - SESUAIKAN JIKA PERLU

# --- FUNGSI NOTIFIKASI TELEGRAM ---
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="${message}" \
        -d parse_mode="Markdown" > /dev/null
}

# Fungsi cleanup & notifikasi akhir
handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_telegram " *Build Gagal!* \nError code: $exit_code. \nCek log terminal Crave."
    else
        send_telegram "✅ *Build Berhasil!* \nMaintainer: $MAINTAINER_NAME"
    fi
    
    echo "[CLEANUP] Menghapus folder $BUILD_DIR..."
    rm -rf "$BUILD_DIR"
    exit $exit_code
}

trap handle_exit EXIT

echo "🚀 Memulai Build Infinity X ($TARGET_DEVICE)..."
send_telegram " *Memulai Build* \nTarget: $TARGET_DEVICE \nMaintainer: $MAINTAINER_NAME"

# 1. Persiapan Folder Build
mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

# 2. Inisialisasi Source Code
rm -rf .repo/local_manifests
repo init --depth=1 --no-repo-verify --git-lfs \
    -u https://github.com/ProjectInfinity-X/manifest \
    -b 16

# 3. Clone Manifest Lokal
git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests

# 4. Sync Source Code (MENGGUNAKAN repo sync STANDAR)
send_telegram "⏳ *Sedang Sync Source Code...* \nMohon tunggu."
repo sync --force-sync --current-branch --no-clone-bundle --no-tags -j$(nproc --all)

# 5. Setup Environment
export INFINITY_MAINTAINER="$MAINTAINER_NAME"
export WITH_GAPPS=$WITH_GAPPS
export TARGET_RELEASE="$TARGET_RELEASE" # WAJIB UNTUK ANDROID 16

source build/envsetup.sh

# 6. Lunch Target (dengan fallback jika nama salah)
LUNCH_TARGET="infinity_${TARGET_DEVICE}-user"
if ! lunch "$LUNCH_TARGET" &>/dev/null; then
    echo "⚠️ Lunch '$LUNCH_TARGET' gagal. Mencoba alternatif..."
    # Coba cari lunch combo yang mengandung 'marble'
    AVAILABLE=$(lunch 2>&1 | grep -i marble | head -1 | awk '{print $2}' | tr -d '.')
    if [ -n "$AVAILABLE" ]; then
        echo "✅ Menemukan alternatif: $AVAILABLE"
        lunch "$AVAILABLE"
    else
        send_telegram " *Lunch Gagal!* \nTidak ditemukan lunch combo untuk $TARGET_DEVICE."
        exit 1
    fi
else
    lunch "$LUNCH_TARGET"
fi

# 7. Mulai Kompilasi
send_telegram "🔨 *Kompilasi Dimulai* \nSedang memproses..."
m bacon
