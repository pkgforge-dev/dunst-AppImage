#!/bin/sh

set -u
ARCH=x86_64
APP=dunst
APPDIR="$APP.AppDir"
SITE="dunst-project/dunst"
EXEC="$APP"

LINUXDEPLOY="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-static-x86_64.AppImage"
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/[()",{} ]/\n/g' | grep -oi 'https.*continuous.*tool.*x86_64.*mage$' | head -1)

# CREATE DIRECTORIES
[ -n "$APP" ] && mkdir -p ./"$APP/$APPDIR" && cd ./"$APP/$APPDIR" || exit 1

# DOWNLOAD AND BUILD ROFI
CURRENTDIR="$(dirname "$(readlink -f "$0")")" # DO NOT MOVE THIS
version=$(wget -q https://api.github.com/repos/"$SITE"/releases/latest -O - | sed 's/[()",{} ]/\n/g' | grep 'https.*.dunst.*tarball' | head -1)
wget "$version" -O download.tar.gz && tar fx ./*tar* && cd ./dunst* || exit 1
WAYLAND=0 \
SYSTEMD=0 \
COMPLETIONS=0 \
make PREFIX="$CURRENTDIR"/usr \
&& make install PREFIX="$CURRENTDIR"/usr \
&& cd .. && rm -rf ./dunst* ./download.tar.gz ./usr/share || exit 1

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$PATH:$CURRENTDIR/usr/bin"

BIN="$ARGV0"
unset ARGV0
case "$BIN" in
	'dunst'|'dunstctl'|'dunstify')
		exec "$CURRENTDIR/usr/bin/$BIN" "$@"
		;;
	'--help')
		"$CURRENTDIR/usr/bin/$BIN" "$@"
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
			exec "$CURRENTDIR"/usr/bin/dunstify "$@"
			;;
		'--ctl')
			shift
			exec "$CURRENTDIR"/usr/bin/dunstctl "$@"
			;;
		esac
	;;
esac
EOF
chmod a+x ./AppRun
APPVERSION=$(echo $version | awk -F / '{print $(NF)}')

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

# MAKE APPIMAGE USING FUSE3 COMPATIBLE APPIMAGETOOL
cd .. && wget "$LINUXDEPLOY" -O linuxdeploy && wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./linuxdeploy ./appimagetool \
&& ./linuxdeploy --appdir "$APPDIR" --executable "$APPDIR"/usr/bin/"$EXEC" && VERSION="$APPVERSION" ./appimagetool -s ./"$APPDIR" || exit 1

[ -n "$APP" ] && mv ./*.AppImage .. && cd .. && rm -rf ./"$APP" && echo "All Done!" || exit 1
