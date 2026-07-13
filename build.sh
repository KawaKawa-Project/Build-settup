#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8912165324:AAGFkpDPjQU5ZFlzgW1QvTjjrzj22Z2cgsA"
TARGET_SEND="7127548846"

# --- KONFIGURASI BUILD ---
MAINTAINER_NAME="OKawaKawa"
WITH_GAPPS=false
TARGET_DEVICE="marble"
TARGET_RELEASE="ap4" # Codename Android 16 VanillaIceCream

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
        send_telegram "❌ *Build Gagal!* \nError code: $exit_code."
    else
        send_telegram "✅ *Build Berhasil!* \nMaintainer: $MAINTAINER_NAME"
    fi
    
    echo "[CLEANUP] Menghapus sisa-sisa proses..."
    # Hapus folder .repo dan out setelah selesai untuk hemat storage Crave
    rm -rf .repo out
    exit $exit_code
}

trap handle_exit EXIT

echo " Membersihkan seluruh isi folder sebelum build dimulai..."
# HAPUS TOTAL SEMUA ISI FOLDER SAAT INI
rm -rf * .[!.]* ..?* 2>/dev/null || true

echo "🚀 Memulai Build Project Infinity X ($TARGET_DEVICE)..."
send_telegram "🚀 *Memulai Build* \nTarget: $TARGET_DEVICE \nMaintainer: $MAINTAINER_NAME"

# 1. Inisialisasi Source Code Android 16
repo init --depth=1 --no-repo-verify --git-lfs \
    -u https://github.com/ProjectInfinity-X/manifest \
    -b 16

# 2. Clone Manifest Lokal untuk Device Tree & Vendor Tree
mkdir -p .repo/local_manifests
git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests

# 3. Sinkronisasi Source Code
send_telegram "⏳ *Sedang Sync Source Code...* \nMohon tunggu."
# Hapus manual folder clang yang sering konflik di Crave
rm -rf prebuilts/clang/host/linux-x86
repo sync --force-sync --current-branch --no-clone-bundle --no-tags -j$(nproc --all)

# 4. Setup Environment & Variabel Maintainer
export INFINITY_MAINTAINER="$MAINTAINER_NAME"
export WITH_GAPPS=$WITH_GAPPS
export TARGET_RELEASE="$TARGET_RELEASE"

source build/envsetup.sh

# 5. Lunch Target dengan Fallback Otomatis
LUNCH_TARGET="infinity_${TARGET_DEVICE}-user"
if ! lunch "$LUNCH_TARGET" &>/dev/null; then
    echo "⚠️ Lunch '$LUNCH_TARGET' gagal. Mencari alternatif..."
    AVAILABLE=$(lunch 2>&1 | grep -i "$TARGET_DEVICE" | head -1 | awk '{print $2}' | tr -d '.')
    if [ -n "$AVAILABLE" ]; then
        echo "✅ Menemukan alternatif: $AVAILABLE"
        lunch "$AVAILABLE"
    else
        send_telegram "❌ *Lunch Gagal!* \nTidak ada combo untuk $TARGET_DEVICE."
        exit 1
    fi
else
    lunch "$LUNCH_TARGET"
fi

# 6. Mulai Kompilasi
send_telegram "🔨 *Kompilasi Dimulai* \nMaintainer: $MAINTAINER_NAME"
m bacon
