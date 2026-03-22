#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q dunst | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export MAIN_BIN=dunst
export ICON=DUMMY
export DESKTOP=DUMMY
export PATH_MAPPING='/etc/dunst:${SHARUN_DIR}/etc/dunst'

# Deploy dependencies
quick-sharun \
	/usr/bin/dunst*        \
	/usr/lib/libnotify.so* \
	/etc/dunst

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
