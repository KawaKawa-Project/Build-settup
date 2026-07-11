#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8912165324:AAFzwMIB-kea9ICh5l3XKbd4E-6To2Dou9w"
TARGET_SEND="7127548846"

# --- KONFIGURASI BUILD ---
MAINTAINER_NAME="OKawaKawa"
WITH_GAPPS=false
TARGET_DEVICE="marble"
BUILD_DIR="BUILD" # Variabel ini wajib ada agar cleanup berfungsi!

# --- FUNGSI NOTIFIKASI TELEGRAM ---
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${TARGET_SEND}" \
        -d text="${message}" \
        -d parse_mode="Markdown" > /dev/null
}

# Fungsi untuk menangani error dan cleanup
handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_telegram "❌ *Build Gagal!* \nProses build Infinity X ($TARGET_DEVICE) terhenti dengan kode error: $exit_code."
    fi
    
    echo "[CLEANUP] Menghapus folder $BUILD_DIR untuk menghemat penyimpanan..."
    rm -rf "$BUILD_DIR"
    
    if [ $exit_code -eq 0 ]; then
        send_telegram "✅ *Build Berhasil!* \nFile ROM telah dihasilkan sebelum folder dihapus. \nMaintainer: $MAINTAINER_NAME"
    fi
    
    exit $exit_code
}

trap handle_exit EXIT

echo "=================================================="
echo "  Memulai Proses Build Project Infinity X ($TARGET_DEVICE)"
echo "  Maintainer: $MAINTAINER_NAME"
echo "=================================================="

send_telegram "🚀 *Memulai Build* \nTarget: Infinity X ($TARGET_DEVICE) \nMaintainer: $MAINTAINER_NAME"

# 1. Persiapan Folder Build
mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

# 2. Inisialisasi Source Code (Tanpa filter grup agar manifest lokal bekerja sempurna)
rm -rf .repo/local_manifests
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16

# 3. Clone Repository Manifest Lokal
git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests

# 4. Sinkronisasi Source Code (MENGGUNAKAN PERINTAH KHUSUS CRAVE)
send_telegram " *Sedang Sync Source Code...* \nMohon tunggu, proses ini memakan waktu lama."
/opt/crave/sync.sh 

# 5. Setup Environment & Konfigurasi
export INFINITY_MAINTAINER="$MAINTAINER_NAME"
export WITH_GAPPS=$WITH_GAPPS

source build/envsetup.sh

# 6. Lunch Target
lunch infinity_${TARGET_DEVICE}-user

# 7. Mulai Kompilasi
send_telegram "🔨 *Kompilasi Dimulai* \nSedang memproses file... Mohon bersabar."
m bacon
