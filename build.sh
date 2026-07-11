#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8912165324:AAFzwMIB-kea9ICh5l3XKbd4E-6To2Dou9w"
TARGET_SEND="7127548846"

# --- KONFIGURASI BUILD ---
MAINTAINER_NAME="OKawaKawa" # Ganti dengan nama kamu
WITH_GAPPS=false            # true jika ingin include Google Apps, false jika ingin vanilla AOSP
TARGET_DEVICE="marble"     # Codename untuk POCO F5 / Redmi Note 12 Turbo
BUILD_DIR="BUILD"          # Nama folder tempat semua proses berlangsung

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

# 1. Persiapan Folder BUILD
echo "[1/7] Menyiapkan direktori kerja di dalam folder $BUILD_DIR..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 2. Persiapan Manifest Lokal
echo "[2/7] Menyiapkan direktori local_manifests..."
mkdir -p .repo/local_manifests

# 3. Clone Repository Manifest
echo "[3/7] Mengambil instruksi build dari aosp-pablo..."
if [ ! -d ".repo/local_manifests/device_manifest" ]; then
    git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests
else
    echo "Manifest sudah ada, melakukan update..."
    cd .repo/local_manifests && git pull && cd ../..
fi

# 4. Sinkronisasi Source Code
echo "[4/7] Sinkronisasi source code (AOSP + Vendor + Kernel + DT)..."
send_telegram "⏳ *Sedang Sync Source Code...* \nMohon tunggu, proses ini memakan waktu lama."
repo sync --force-sync --current-branch --no-clone-bundle --no-tags -j$(nproc --all)

# 5. Setup Environment & Konfigurasi
echo "[5/7] Mengatur environment build..."
export INFINITY_MAINTAINER="$MAINTAINER_NAME"
export WITH_GAPPS=$WITH_GAPPS

source build/envsetup.sh

# 6. Lunch Target
echo "[6/7] Memilih target perangkat: infinity_${TARGET_DEVICE}-user..."
lunch infinity_${TARGET_DEVICE}-user

# 7. Mulai Kompilasi
echo "[7/7] Memulai kompilasi 'm bacon'..."
send_telegram "🔨 *Kompilasi Dimulai* \nSedang memproses file... Mohon bersabar."
m bacon

# Catatan: Jika m bacon berhasil, script akan lanjut ke trap handle_exit dengan exit_code 0
