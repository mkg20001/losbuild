#!/bin/bash

# set -euo pipefail

SELF=$(dirname $(readlink -f $0))

DEVICE="marlin"
VENDOR="google"
VERSION="17.1"

PACKAGES="fdroid gapps su twrp" # charger

GAPPS_VARIANT="nano"

# code

SLUG="$VENDOR/$DEVICE"
PACKAGES="muppets los $PACKAGES"

mkdir -p ~/android/lineage
cd ~/android/lineage

if [ ! -e .repo ]; then
  repo init -u https://github.com/LineageOS/android.git -b "lineage-$DEVICE"
  repo sync
fi

mk_snip() {
  SNIP="'<include name=\"snippets/$1.xml\" />'"
}

contains() {
  if cat "$1" | grep "$2" > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

add_snip() {
  mk_snip "$1"
  mkdir -p .repo/local_manifests
  cp $SELF/$1.xml .repo/local_manifests/$1.xml
  # cp $SELF/$1.xml .repo/manifests/snippets/$1.xml
  # if ! contains .repo/manifests/default.xml "$SNIP"; then
  #   sed "s|</manifest>|$SNIP</manifest>|" > .repo/manifests/default.xml
  # fi
}

pre_los() {
  :
  # the muppets does this for us
  # pushd "~/android/lineage/device/$SLUG"
  # ./extract-files.sh
  # popd
}

post_los() {
  :
  breakfast "$DEVICE"
}

pre_gapps() {
  # from https://github.com/opengapps/aosp_build#getting-started
  add_snip opengapps
}

post_gapps() {
  DEV_FILE="device/$SLUG/device-$DEVICE.mk"
  if ! contains "$DEV_FILE" "opengapps"; then
    # cp "$DEV_FILE" "$DEV_FILE.bak"
    sed -i "1s|^|GAPPS_VARIANT := $GAPPS_VARIANT\n|" "$DEV_FILE"
    echo '$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)' >> "$DEV_FILE"
  fi

  echo > vendor/opengapps/build/modules/CarrierServices/Android.mk # los has it built-in

  for src in vendor/opengapps/sources/*; do
    pushd $src
    git lfs pull
    popd
  done
}

pre_fdroid() {
  # from https://gitlab.com/fdroid/android_vendor_fdroid#getting-the-packages
  add_snip fdroid
}

post_fdroid() {
  pushd vendor/fdroid
  bash $SELF/make-fdroid-list.sh
  echo "-app/org.fdroid.fdroid_1001002.apk:app/FDroid.apk;PRESIGNED
-priv-app/org.fdroid.fdroid.privileged_2070.apk:priv-app/FDroidPrivilegedExtension.apk;PRESIGNED"
  ./get_packages.sh
  popd
}

pre_muppets() {
  # from https://forum.xda-developers.com/showpost.php?s=a6ee98b07b1b0a2f4004b902a65d9dcd&p=76981184&postcount=4 and https://github.com/TheMuppets/manifests & https://gist.github.com/fourkbomb/261ced58cd029c5f7742350aafdd9825
  echo '<?xml version="1.0" encoding="UTF-8"?>
  <manifest>
    <project name="TheMuppets/proprietary_vendor_'"$VENDOR"'" path="vendor/'"$VENDOR"'"/>
  </manifest>' > $SELF/muppets_local.xml
  add_snip muppets_local
}

post_muppets() {
  :
  # nothing, congrats!
}

pre_twrp() {
  export WITH_TWRP=true
}

post_twrp() {
  :
}

pre_su() {
  export WITH_SU=true
}

post_su() {
  :
}

pre_charger() {
  export WITH_LINEAGE_CHARGER=true
}

post_charger() {
  :
}

# PRE

for pkg in $PACKAGES; do
  "pre_$pkg"
done

# MAIN

repo sync

# POST

source build/envsetup.sh

for pkg in $PACKAGES; do
  "post_$pkg"
done

# build

croot
brunch "$DEVICE"
