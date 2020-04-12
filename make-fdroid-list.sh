#!/bin/bash

set -euo pipefail

wget https://f-droid.org/repo/index.jar
unzip index.jar
F_PRIV=$(cat index.xml | grep -o "org.fdroid.fdroid.privileged_[0-9]*.apk" | head -n 1)
F_APP=$(cat index.xml | grep -o "org.fdroid.fdroid_[0-9]*.apk" | head -n 1)

echo "-app/$F_APP:app/FDroid.apk;PRESIGNED
-priv-app/$F_PRIV:priv-app/FDroidPrivilegedExtension.apk;PRESIGNED" > repo/fdroid.txt
