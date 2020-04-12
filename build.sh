#!/bin/bash

set -euo pipefail

SELF=$(dirname $(readlink -f $0))

DEVICE="marlin"
VENDOR="google"
VERSION="17.1"

PACKAGES="fdroid gapps"

GAPPS_VARIANT="nano"

# code

SLUG="$VENDOR/$DEVICE"
PACKAGES="muppets los $PACKAGES"

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

pre_los() {
  ::
  # pushd "~/android/lineage/device/$SLUG"
  # ./extract-files.sh
  # popd
}

post_los() {
  ::
  breakfast "$DEVICE"
}

pre_gapps() {
  # from https://github.com/opengapps/aosp_build#getting-started
  add_snip opengapps
}

post_gapps() {
  pushd vendor/fdroid
  ./get_packages.sh
  popd
}

pre_fdroid() {
  # from https://gitlab.com/fdroid/android_vendor_fdroid#getting-the-packages
  add_snip fdroid
}

pre_muppets() {
  # from https://forum.xda-developers.com/showpost.php?s=a6ee98b07b1b0a2f4004b902a65d9dcd&p=76981184&postcount=4 and https://github.com/TheMuppets/manifests
  add_snip muppets
}

post_muppets() {
  ::
  # nothing, congrats!
}

post_fdroid() {
  DEV_FILE="device/$SLUG/device.mk"
  cp "$DEV_FILE" "$DEV_FILE.bak"
  sed -i "1s|^|GAPPS_VARIANT := $GAPPS_VARIANT|" "$DEV_FILE"
  echo '$(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)' >> "$DEV_FILE"
}

# PRE

for $pkg in $PACKAGES; do
  "pre_$pkg"
done

# MAIN

repo sync

# POST

source build/envsetup.sh

for $pkg in $PACKAGES; do
  "post_$pkg"
done

# build

croot
brunch "$DEVICE"
