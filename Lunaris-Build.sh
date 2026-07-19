#!/bin/bash

# 1. Initial ROM source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs

# 2. Sync ROM 
/opt/crave/resync.sh

# 3. Clone device tree
rm -rf device/xiaomi/marble
git clone https://github.com/KawaKawa-Project/device_xiaomi_marble_by_aosp_pablo.git -b Lunaris-16.2 device/xiaomi/marble

# 4. Clone vendor tree 
rm -rf vendor/xiaomi/marble
git clone --depth=1 https://github.com/KawaKawa-Project/vendor_xiaomi_marble_by_pablo.git -b 16 vendor/xiaomi/marble

# 5. Start the build ROM
. build/envsetup.sh

# lunch
lunch lineage_marble-bp4a-userdebug
m bacon

# 6. Upload to Gofile 
if [ -f out/target/product/marble/*202607*.zip ]; then
  wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
  chmod +x upload.sh ; ./upload.sh out/target/product/marble/*202607*.zip
else
  echo "zip not found out/target/product/marble/"
fi
