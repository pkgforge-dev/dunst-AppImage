#!/bin/sh

APP=dunst
APPDIR="$APP.AppDir"
SITE="dunst-project/dunst"
EXEC="$APP"

# CREATE DIRECTORIES
[ -n "$APP" ] && mkdir -p ./"$APP/$APPDIR" && cd ./"$APP/$APPDIR" || exit 1

# DOWNLOAD AND BUILD ROFI
CURRENTDIR="$(dirname "$(readlink -f "$0")")" # DO NOT MOVE THIS
version=$(wget -q https://api.github.com/repos/"$SITE"/releases/latest -O - | sed 's/[()",{}]/ /g; s/ /\n/g' | grep 'https.*.dunst.*tarball' | head -1)
wget "$version" -O download.tar.gz && tar fx ./*tar* && cd ./dunst* || exit 1
WAYLAND=0 \
SYSTEMD=0 \
COMPLETIONS=0 \
make PREFIX="$CURRENTDIR"/usr \
&& make install PREFIX="$CURRENTDIR"/usr \
&& cd .. && rm -rf ./dunst* ./download.tar.gz ./*.AppDir/usr/share || exit 1

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/bash
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$PATH:$CURRENTDIR/bin"
if [ "$1" = "notify" ]; then
	"$CURRENTDIR/usr/bin/dunstify" "${@:2}"
elif [ "$1" = "ctl" ]; then
	"$CURRENTDIR/usr/bin/dunstctl" "${@:2}"
else
	"$CURRENTDIR/usr/bin/dunst" "$@"
fi
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

# MAKE APPIMAGE
LINUXDEPLOY="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-static-x86_64.AppImage"
cd .. && wget "$LINUXDEPLOY" -O linuxdeploy && chmod a+x ./linuxdeploy && ./linuxdeploy --appdir "$APPDIR" --executable "$APPDIR"/usr/bin/"$EXEC" --output appimage

# LIBFUSE3
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')

[ -n "$APPDIR" ] && ls *AppImage && rm -rf ./"$APPDIR" || exit 1
./*AppImage --appimage-extract && mv ./squashfs-root ./"$APPDIR" && rm -f ./*AppImage && wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./appimagetool || exit 1

# Do the thing!
ARCH=x86_64 VERSION="$APPVERSION" ./appimagetool -s ./"$APPDIR" || exit 1
[ -n "$APP" ] && mv ./*.AppImage .. && cd .. && rm -rf ./"$APP" && echo "All Done!" || exit 1
