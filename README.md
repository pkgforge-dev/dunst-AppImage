# dunst-AppImage
Unofficial AppImage of dunst https://github.com/dunst-project/dunst

# READ THIS

Works like the regular dunst, by default running the appimage does the same as running the regular `dunst` binary. 

If you want to use `dunstify` or `dunstctl` you will have to instead run the appimage + ctl/notify, that is: `dunstify` becomes `appimagename notify` and `dunstctl` becomes `dunst ctl`.

You can set up wrapper scripts with the names of the original binaries so that it is automatically compatible. Installing this appimage with AM will do so:  https://github.com/ivan-hc/AM

It is possible that this appimage may fail to work with appimagelauncher, for that I recommend AM as an alternative again.

This appimage works without fuse2 as it can use fuse3 instead.
