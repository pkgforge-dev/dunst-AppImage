#!/bin/sh

set -eu
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|dunst-AppImage|latest|*$ARCH.AppImage.zsync"
APP=dunst
APPDIR="$APP.AppDir"
SITE="dunst-project/dunst"

APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
SHARUN="https://bin.ajam.dev/$(uname -m)/sharun"

# CREATE DIRECTORIES
mkdir -p ./"$APP/$APPDIR"
cd ./"$APP/$APPDIR"

# DOWNLOAD
HERE="$(dirname "$(readlink -f "$0")")" # DO NOT MOVE THIS
version=$(wget -q https://api.github.com/repos/"$SITE"/releases/latest -O - \
	| sed 's/[()",{} ]/\n/g' | grep 'https.*.dunst.*tarball' | head -1)
wget "$version" -O download.tar.gz
tar fx ./*tar* && cd ./dunst*

export VERSION="$(echo $version | awk -F"/" '{print $(NF)}')"

# BUILD DUNST
export COMPLETIONS=0
make PREFIX="$HERE"/shared
make install PREFIX="$HERE"/shared

cd ..
rm -rf ./dunst* ./download.tar.gz

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$CURRENTDIR/bin:$PATH"
[ -z "$APPIMAGE" ] && APPIMAGE="$0"

BIN="${ARGV0#./}"
unset ARGV0
if [ -f "$CURRENTDIR/bin/$BIN" ]; then
	exec "$CURRENTDIR/bin/$BIN" "$@"
elif [ "$1" = "--notify" ]; then
	shift
	exec "$CURRENTDIR"/bin/dunstify "$@"
elif [ "$1" = "--ctl" ]; then
	shift
	exec "$CURRENTDIR"/bin/dunstctl "$@"
else
	if [ -z "$1" ]; then
		echo "AppImage commands:"
		echo " \"$APPIMAGE\"            runs dunst"
		echo " \"$APPIMAGE --notify\"   runs dunstify"
		echo " \"$APPIMAGE --ctl\"      runs dunstctl"
		echo "You can also make symlinks to the AppImage with the names"
		echo "dunstify and dunstctl and that will make it automatically"
		echo "launch those binaries without needing to use extra flags"
		echo "running dunst..."
	fi
	"$CURRENTDIR/bin/dunst" "$@"
fi
EOF
chmod a+x ./AppRun

# Dummy Icon & Desktop
touch ./dunst.png && ln -s ./dunst.png ./.DirIcon
cat >> ./"$APP.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=dunst
Icon=dunst
Exec=dunst
Categories=System
Hidden=true
EOF

# DEPLOY ALL LIBS
mkdir -p ./bin
mv ./shared/bin/dunstctl ./bin

wget "$LIB4BN" -O ./lib4bin
wget "$SHARUN" -O ./sharun
chmod +x ./lib4bin ./sharun
HARD_LINKS=1 ./lib4bin ./shared/bin/*
rm -f ./lib4bin

# Do the thing!
cd ..
wget -q "$APPIMAGETOOL" -O appimagetool
chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n -u "$UPINFO" ./"$APPDIR" dunst-"$VERSION"-"$ARCH".AppImage

mv ./*.AppImage ../ 
cd .. 
rm -rf "$APP"
echo "All Done!"
