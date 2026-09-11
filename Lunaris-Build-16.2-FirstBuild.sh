#!/bin/bash

# 1. Clean Build
rm -rf .repo/local_manifests
rm -rf device/xiaomi/marble device/xiaomi/sm8450-common
rm -rf vendor/xiaomi/marble vendor/xiaomi/sm8450-common vendor/xiaomi/marble-firmware
rm -rf device/xiaomi/miuicamera-marble vendor/xiaomi/miuicamera-marble
rm -rf hardware/xiaomi hardware/dolby
rm -rf kernel/xiaomi/sm8450 kernel/xiaomi/sm8450-modules kernel/xiaomi/sm8450-devicetrees

# 2. Init Rom
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs --depth=1
/opt/crave/resync.sh

# Device 
git clone https://github.com/KawaKawa-Project/device_xiaomi_marble_by_aosp_pablo.git -b LunarisAOSP device/xiaomi/marble
git clone https://github.com/KawaKawa-Project/device_xiaomi_sm8450-common_by_aosp_pablo.git -b LunarisAOSP device/xiaomi/sm8450-common

# Vendor
git clone https://github.com/KawaKawa-Project/vendor_xiaomi_marble_by_pablo.git -b LunarisAOSP --depth=1 vendor/xiaomi/marble
git clone https://github.com/KawaKawa-Project/vendor_xiaomi_sm8450-common_by_aosp_pablo.git -b LunarisAOSP --depth=1 vendor/xiaomi/sm8450-common
git clone https://github.com/KawaKawa-Project/vendor_xiaomi_marble-firmware_by_aosp_pablo.git -b LunarisAOSP --depth=1 vendor/xiaomi/marble-firmware

# MIUI Camera
git clone https://github.com/KawaKawa-Project/device_xiaomi_miuicamera-marble_by_aosp_pablo.git -b 16 device/xiaomi/miuicamera-marble
git clone https://github.com/KawaKawa-Project/vendor_xiaomi_miuicamera-marble_by_aosp_pablo.git -b 16 --depth=1 vendor/xiaomi/miuicamera-marble

# Hardware & Dolby
git clone https://github.com/KawaKawa-Project/android_hardware_xiaomi_by_aosp_pablo.git -b lineage-23.0 hardware/xiaomi
git clone https://github.com/KawaKawa-Project/hardware_dolby_by_aosp_pablo.git -b xiaomi-blobs hardware/dolby

# Kernel
git clone https://github.com/KawaKawa-Project/android_kernel_xiaomi_sm8450_by_aosp_pablo.git -b LunarisAOSP --depth=1 kernel/xiaomi/sm8450
git clone https://github.com/KawaKawa-Project/android_kernel_xiaomi_sm8450-modules_by_aosp_pablo.git -b LunarisAOSP --depth=1 kernel/xiaomi/sm8450-modules
git clone https://github.com/KawaKawa-Project/android_kernel_xiaomi_sm8450-devicetrees_by_aosp_pablo.git -b LunarisAOSP --depth=1 kernel/xiaomi/sm8450-devicetrees

# 3. Inject Release Keys Private
git clone https://github.com/KawaKawa-Project/sign.git -b keys vendor/lineage-priv/keys

# 4. Start
. build/envsetup.sh
lunch lineage_marble-bp4a-userdebug
make installclean
m bacon
