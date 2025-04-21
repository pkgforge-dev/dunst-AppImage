#!/bin/sh

set -ex

TARBALL=$(wget https://api.github.com/repos/dunst-project/dunst/releases/latest -O - \
	| sed 's/[()",{} ]/\n/g' | grep 'https.*.dunst.*tarball' | head -1)

export COMPLETIONS=0

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
apk add \
	bash \
	build-base \
	coreutils \
	dbus \
	dbus-dev \
	desktop-file-utils \
	git \
	libnotify-dev \
	librsvg \
	libxinerama-dev \
	libxrandr-dev \
	libxscrnsaver-dev \
	pango-dev \
	patchelf \
	perl \
	wayland-dev \
	wayland-protocols \
	wget

echo "Building dunst..."
wget "$TARBALL" -O download.tar.gz
tar fx ./*.tar.* && (
	cd ./dunst*
	make -j$(nproc)
	make install
)
rm -rf ./dunst* ./download.tar.gz

echo "All done!"
echo "---------------------------------------------------------------"
