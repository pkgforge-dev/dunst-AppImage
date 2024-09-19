# dunst-AppImage
Unofficial AppImage of dunst https://github.com/dunst-project/dunst

# READ THIS

Works like the regular dunst, by default running the appimage does the same as running the regular `dunst` binary. 

If you want to use `dunstify` or `dunstctl` you will have to symlink the appimage with the name of the symlink being `dunstify` or `dunstctl`, and by launching those symlinks the appimage knows that you want to launch `dunstify` or `dunstctl` since the appimage can know the name of the symlink it was launched with.

It is possible that this appimage may fail to work with appimagelauncher, for that I recommend AM as an alternative again.

This appimage works without fuse2 as it can use fuse3 instead.
