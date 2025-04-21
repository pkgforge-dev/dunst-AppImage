#!/bin/sh

set -eux

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
APPIMAGETOOL="https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"

# CREATE DIRECTORIES
mkdir ./AppDir
cd ./AppDir

# AppRun
echo '#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$CURRENTDIR/usr/bin:$PATH"
[ -n "$APPIMAGE" ] || APPIMAGE="$0"
BIN="${ARGV0#./}"
unset ARGV0
if [ -f "$CURRENTDIR/usr/bin/$BIN" ]; then
	if [ "$BIN" = "dunstctl" ]; then
		exec "$CURRENTDIR/usr/bin/$BIN" "$@"
	else
		exec "$CURRENTDIR/ld-musl.so" "$CURRENTDIR/usr/bin/$BIN" "$@"
	fi
elif [ "$1" = "--notify" ]; then
	shift
	exec "$CURRENTDIR/ld-musl.so" "$CURRENTDIR"/usr/bin/dunstify "$@"
elif [ "$1" = "--ctl" ]; then
	shift
	exec "$CURRENTDIR"/usr/bin/dunstctl "$@"
else
	if [ -z "$1" ]; then
		echo "AppImage commands:"
		echo " \"$APPIMAGE\"            runs dunst"
		echo " \"$APPIMAGE --notify\"   runs dunstify"
		echo " \"$APPIMAGE --ctl\"      runs dunstctl"
		echo "You can also make and run symlinks to the AppImage with the names"
		echo "dunstify and dunstctl to launch them automatically without extra args"
		echo "running dunst..."
	fi
	exec "$CURRENTDIR/ld-musl.so" "$CURRENTDIR/usr/bin/dunst" "$@"
fi' > ./AppRun
chmod +x ./AppRun

# Dummy Icon & Desktop
touch ./dunst.png ./.DirIcon # No official icon?
echo '[Desktop Entry]
Type=Application
Name=dunst
Icon=dunst
Exec=dunst
Categories=System
Hidden=true' > dunst.desktop

# DEPLOY ALL LIBS
mkdir -p ./usr/lib ./usr/bin ./etc/xdg

cp -vr /usr/local/etc/xdg/dunst   ./etc/xdg
cp -v /usr/local/bin/dunst*       ./usr/bin
cp -v /usr/lib/libnotify.so*      ./usr/lib
cp -v /lib64/ld-musl-*.so.2       ./ld-musl.so

ldd ./usr/bin/* ./usr/lib/* \
	| awk -F"[> ]" '{print $4}' | xargs -I {} cp -vf {} ./usr/lib

find ./usr -type f -exec patchelf --set-rpath '$ORIGIN:$ORIGIN/../lib' {} ';'
find ./usr -type f -exec strip -s -R .comment --strip-unneeded {} ';'

export VERSION="$(./AppRun --version | awk 'FNR==1 {print $NF}')"
[ -n "$VERSION" ]
echo "$VERSION" > ~/version

# Do the thing!
cd ..
wget "$APPIMAGETOOL" -O appimagetool
chmod +x ./appimagetool
URUNTIME_PRELOAD=1 \
	./appimagetool -n -u \
	"$UPINFO" ./AppDir ./dunst-"$VERSION"-anylinux-"$ARCH".AppImage

echo "All Done!"
