#!/bin/sh

set -u
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
[ -n "$APP" ] && mkdir -p ./"$APP/$APPDIR" && cd ./"$APP/$APPDIR" || exit 1

# DOWNLOAD AND BUILD ROFI
HERE="$(dirname "$(readlink -f "$0")")" # DO NOT MOVE THIS
version=$(wget -q https://api.github.com/repos/"$SITE"/releases/latest -O - \
	| sed 's/[()",{} ]/\n/g' | grep 'https.*.dunst.*tarball' | head -1)

export VERSION="$(echo $version | awk -F"/" '{print $(NF)}')"

wget "$version" -O download.tar.gz && tar fx ./*tar* && cd ./dunst* || exit 1

WAYLAND=0 SYSTEMD=0 COMPLETIONS=0 \
	make PREFIX="$HERE"/usr && make install PREFIX="$HERE"/usr || exit 1

cd .. && rm -rf ./dunst* ./download.tar.gz ./usr/share || exit 1

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$CURRENTDIR/bin:$PATH"

BIN="${ARGV0#./}"
unset ARGV0
case "$BIN" in
	'dunst'|'dunstctl'|'dunstify')
		exec "$CURRENTDIR/bin/$BIN" "$@"
		;;
	'--help')
		"$CURRENTDIR/bin/$BIN" "$@"
		echo "By default running the AppImage runs the dunst binary"
		echo "AppImage commands:"
		echo " \"--notify\"   runs dunstify"
		echo " \"--ctl\"      runs dunstctl"
		echo "You can also make symlinks to the AppImage with the names"
		echo "dunstify and dunstctl and that will make it automatically"
		echo "launch those binaries without needing to use extra flags"
		echo "since it can read the name of the symlink that started it"
		;;

	*)
		case "$1" in
		'--notify')
			shift
			exec "$CURRENTDIR"/bin/dunstify "$@"
			;;
		'--ctl')
			shift
			exec "$CURRENTDIR"/bin/dunstctl "$@"
			;;
		esac
	;;
esac
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
mv ./usr ./shared
mkdir -p ./bin && mv ./shared/bin/dunstctl ./bin || exit 1

wget "$LIB4BN" -O ./lib4bin && wget "$SHARUN" -O ./sharun || exit 1
chmod +x ./lib4bin ./sharun
HARD_LINKS=1 ./lib4bin ./shared/bin/* && rm -f ./lib4bin || exit 1

# Do the thing!
cd .. && wget -q "$APPIMAGETOOL" -O appimagetool && chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n -u "$UPINFO" ./"$APPDIR" dunst-"$VERSION"-"$ARCH".AppImage

mv ./*.AppImage .. && cd .. && rm -rf "$APP" || exit 1
echo "All Done!"
