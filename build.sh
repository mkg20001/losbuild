#!/bin/bash

set -euo pipefail

SELF=$(dirname $(readlink -f $0))

DEVICE="marlin"
VENDOR="google"
VERSION="17.1"

GAPPS_VARIANT="nano"

# code

SLUG="$VENDOR/$DEVICE"

mkdir -p ~/bin
mkdir -p ~/android/lineage

if [ ! -e ~/bin/repo ]; then
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

pushd ~/android/lineage
if [ ! -e .repo ]; then
  repo init -u https://github.com/LineageOS/android.git -b "lineage-$DEVICE"
  repo sync
fi

mk_snip() {
  SNIP="'<include name=\"snippets/$1.xml\" />'"
}

contains() {
  if ! cat "$1" | grep "$2" > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

add_snip() {
  mk_snip "$1"
  cp $SELF/$1.xml .repo/manifests/snippets/$1.xml
  if ! contains .repo/manifests/default.xml "$SNIP"; then
    sed "s|</manifest>|$SNIP</manifest>" > .repo/manifests/default.xml
  fi
}

# PRE

# from https://github.com/opengapps/aosp_build#getting-started
add_snip opengapps

# from https://gitlab.com/fdroid/android_vendor_fdroid#getting-the-packages
add_snip fdroid

# MAIN

repo sync

# POST

source build/envsetup.sh

# los

breakfast "$DEVICE"

pushd "~/android/lineage/device/$SLUG"
./extract-files.sh
popd

# fdroid

pushd vendor/fdroid
./get_packages.sh
popd

# gapps

DEV_FILE="device/$SLUG/device.mk"
cp "$DEV_FILE" "$DEV_FILE.bak"
sed -i "1s|^|GAPPS_VARIANT := $GAPPS_VARIANT|" "$DEV_FILE"
echo '$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)' >> "$DEV_FILE"

# build

croot
brunch "$DEVICE"
