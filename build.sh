#!/bin/bash

TOKEN="8912165324:AAGFkpDPjQU5ZFlzgW1QvTjjrzj22Z2cgsA"
TARGET_SEND="7127548846"

MAINTAINER_NAME="OKawaKawa"
WITH_GAPPS=false
TARGET_DEVICE="marble"
TARGET_RELEASE="ap4"

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
        send_telegram "❌ Gagal ($exit_code)"
    else
        send_telegram "✅ Setup Selesai"
    fi
    exit $exit_code
}

trap handle_exit EXIT

[ ! -d ".repo" ] && repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16

mkdir -p .repo/local_manifests
[ -d ".repo/local_manifests/.git" ] && (cd .repo/local_manifests && git pull && cd ../..) || git clone -b infinity https://github.com/aosp-pablo/device_manifest.git .repo/local_manifests

send_telegram "🔄 Sync"
/opt/crave/resync.sh

export INFINITY_MAINTAINER="$MAINTAINER_NAME" WITH_GAPPS=$WITH_GAPPS TARGET_RELEASE="$TARGET_RELEASE"
source build/envsetup.sh

LUNCH_TARGET="infinity_${TARGET_DEVICE}-user"
if ! lunch "$LUNCH_TARGET" &>/dev/null; then
    AVAILABLE=$(lunch 2>&1 | grep -i "$TARGET_DEVICE" | head -1 | awk '{print $2}' | tr -d '.')
    [ -n "$AVAILABLE" ] && lunch "$AVAILABLE" || { send_telegram "❌ Lunch gagal"; exit 1; }
else
    lunch "$LUNCH_TARGET"
fi
