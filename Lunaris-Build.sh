#!/bin/bash

#initial rom source
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs

#sync rom 
/opt/crave/resync.sh

#clone github device tree
git clone https://github.com/KawaKawa-Project/device_xiaomi_marble_by_aosp_pablo.git -b Lunaris-16.2 device/xiaomi/marble

#clone vendor tree and remove default vendor rom
rm -rf vendor/lineage
git clone --depth=1 https://github.com/KawaKawa-Project/vendor_xiaomi_marble_by_pablo.git -b 16 vendor/lineage

#start the build rom
. build/envsetup.sh
lunch lineage_marble-bp4a-userdebug
m bacon

#upload to gofile
if [ -f out/target/product/earth/*202607*.zip ]; then
  wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
  chmod +x upload.sh ; ./upload.sh out/target/product/earth/*202607*.zip
fi
