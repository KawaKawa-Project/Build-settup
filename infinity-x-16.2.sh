#!/bin/bash
set -e

# Clean

rm -rf .repo/local_manifests
rm -rf \
    device/xiaomi/marble \
    device/xiaomi/sm8450-common \
    vendor/xiaomi/marble \
    vendor/xiaomi/sm8450-common \
    vendor/xiaomi/marble-firmware \
    device/xiaomi/miuicamera-marble \
    vendor/xiaomi/miuicamera-marble \
    hardware/xiaomi \
    hardware/dolby \
    kernel/xiaomi/sm8450 \
    kernel/xiaomi/sm8450-modules \
    kernel/xiaomi/sm8450-devicetrees


# 1. Initial ROM source

repo init \
    --depth=1 \
    --no-repo-verify \
    --git-lfs \
    -u https://github.com/ProjectInfinity-X/manifest \
    -b 16 \
    -g default,-mips,-darwin,-notdefault


# 2. Sync base ROM

/opt/crave/resync.sh


# 3. Device

git clone \
    --depth=1 \
    --single-branch \
    -b infinity \
    https://github.com/KawaKawa-Project/device_xiaomi_marble.git\
    device/xiaomi/marble
git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/device_xiaomi_sm8450-common.git \
    device/xiaomi/sm8450-common


# 4. Vendor

git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/vendor_xiaomi_marble.git \
    vendor/xiaomi/marble
git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/vendor_xiaomi_sm8450-common.git \
    vendor/xiaomi/sm8450-common


# 5. Firmware

git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/vendor_xiaomi_marble-firmware.git \
    vendor/xiaomi/marble-firmware


# 6. MIUI Camera

git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/device_xiaomi_miuicamera-marble.git \
    device/xiaomi/miuicamera-marble
git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/vendor_xiaomi_miuicamera-marble.git \
    vendor/xiaomi/miuicamera-marble


# 7. Hardware Xiaomi

git clone \
    --depth=1 \
    --single-branch \
    -b lineage-23.0 \
    https://github.com/aosp-pablo/android_hardware_xiaomi.git \
    hardware/xiaomi


# 8. Dolby

git clone \
    --depth=1 \
    --single-branch \
    -b xiaomi-blobs \
    https://github.com/aosp-pablo/hardware_dolby.git \
    hardware/dolby


# 9. Kernel

git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/android_kernel_xiaomi_sm8450.git \
    kernel/xiaomi/sm8450
git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/android_kernel_xiaomi_sm8450-modules.git \
    kernel/xiaomi/sm8450-modules
git clone \
    --depth=1 \
    --single-branch \
    -b 16 \
    https://github.com/aosp-pablo/android_kernel_xiaomi_sm8450-devicetrees.git \
    kernel/xiaomi/sm8450-devicetrees


# 10. Add Release Keys

git clone \
    --depth=1 \
    --single-branch \
    -b keys \
    https://github.com/KawaKawa-Project/sign.git \
    vendor/infinity-priv/keys


# 12. Add Root - ReSukiSU

cd kernel/xiaomi/sm8450
curl -LSs \
    "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" \
    | bash
cd -


# 13. Start build 

. build/envsetup.sh


# 14. Lunch & Build

lunch infinity_marble-userdebug
make installclean
m bacon
