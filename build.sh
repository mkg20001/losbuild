#!/bin/bash

set -euo pipefail

DEVICE="marlin"
VENDOR="google"
VERSION="17.1"

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
fi

repo sync

source build/envsetup.sh
breakfast marlin

pushd "~/android/lineage/device/$SLUG"
./extract-files.sh
popd

croot
brunch marlin

# from https://github.com/opengapps/aosp_build#getting-started
