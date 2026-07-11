#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8912165324:AAFzwMIB-kea9ICh5l3XKbd4E-6To2Dou9w"
TARGET_SEND="7127548846"

# --- KONFIGURASI BUILD ---
MAINTAINER_NAME="OKawaKawa" # Ganti dengan nama kamu
WITH_GAPPS=false            # true jika ingin include Google Apps, false jika ingin vanilla AOSP
TARGET_DEVICE="marble"     # Codename untuk POCO F5 / Redmi Note 12 Turbo

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
        send_telegram "❌ *Build Gagal!* \nProses build Infinity X ($TARGET_DEVICE) terhenti dengan kode error: $exit_code. \nCek log terminal Crave untuk detailnya."
    fi
    
    echo "[CLEANUP] Menghapus folder $BUILD_DIR untuk menghemat penyimpanan..."
    rm -rf "$BUILD_DIR"
    
    if [ $exit_code -eq 0 ]; then
        send_telegram "✅ *Build Berhasil!* \nFile ROM telah dihasilkan sebelum folder dihapus. \nMaintainer: $MAINTAINER_NAME"
    fi
    
    exit $exit_code
}

# Mendaftarkan trap agar cleanup berjalan meski script dihentikan paksa atau error
trap handle_exit EXIT

echo "=================================================="
echo "  Memulai Proses Build Project Infinity X ($TARGET_DEVICE)"
echo "  Maintainer: $MAINTAINER_NAME"
echo "=================================================="

# Kirim notifikasi awal
send_telegram "🚀 *Memulai Build* \nTarget: Infinity X ($TARGET_DEVICE) \nMaintainer: $MAINTAINER_NAME \nStatus: Sedang menyiapkan environment..."

# Remove source code before
rm -rf .repo/local_manifests

# 1. init source
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# 3. Clone Repository Manifest
git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests

# 4. Sinkronisasi Source Code
lsend_telegram "⏳ *Sedang Sync Source Code...* \Mohon tunggu, proses ini memakan waktu lama."
/opt/crave/sync.sh # crave repo sync

# 5. Setup Environment & Konfigurasi
export INFINITY_MAINTAINER="$MAINTAINER_NAME"
export WITH_GAPPS=$WITH_GAPPS

. build/envsetup.sh

# 6. Lunch Target
lunch infinity_${TARGET_DEVICE}-user

# 7. Mulai Kompilasi
send_telegram "🔨 *Kompilasi Dimulai* \nSedang memproses file... Mohon bersabar."
m bacon

# Catatan: Jika m bacon berhasil, script akan lanjut ke trap handle_exit dengan exit_code 0
