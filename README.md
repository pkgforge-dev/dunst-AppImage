# dunst-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/dunst-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/dunst-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/dunst-AppImage/actions/workflows/blank.yml/badge.svg)](https://github.com/pkgforge-dev/dunst-AppImage/releases/latest)

* [Latest Stable Release](https://github.com/pkgforge-dev/dunst-AppImage/releases/latest)

---

Works like the regular dunst, by default running the appimage does the same as running the regular `dunst` binary. 

Passing the flags `--ctl` or `--notify` make the appimage launch dunstctl or dunstify, you can also symlink the appimage with the names `dunstify` and `dunstctl` and that way by running those symlinks it automatically launches those commands without extra arguments. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i dunst` or `appman -i dunst`

* [dbin](https://github.com/xplshn/dbin) `dbin install dunst.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install dunst`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

