# dunst-AppImage
Unofficial AppImage of dunst https://github.com/dunst-project/dunst

Works like the regular dunst, by default running the appimage does the same as running the regular `dunst` binary. 

Passing the flags `--ctl` or `--notify` make the appimage launch dunstctl or dunstify, you can also symlink the appimage with the names `dunstify` and `dunstctl` and that way by running those symlinks it automatically launches those commands without extra arguments. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend this alternative instead: https://github.com/ivan-hc/AM

This appimage works without fuse2 as it can use fuse3 instead.
