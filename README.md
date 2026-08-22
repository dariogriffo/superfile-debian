![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/superfile-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/superfile-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/superfile-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/superfile-debian)

<h1>
   <p align="center">
     <a href="https://superfile.dev/"><img src="https://github.com/dariogriffo/superfile-debian/blob/main/superfile.svg" alt="superfile Logo" width="220" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/superfile-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>superfile for Debian
   </p>
</h1>
<p align="center">
 superfile is a pretty fancy and modern terminal file manager, with multi-panel browsing, previews, and a built-in trash bin.
</p>

# superfile for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [superfile](https://github.com/yorukot/superfile/) hosted at [deb.griffo.io](https://deb.griffo.io)

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

Currently supported Ubuntu distros are:
- Jammy (22.04)
- Noble (24.04)
- Questing (25.10)
- Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream publishes no i386, armel, armhf or riscv64 binaries, so those
architectures are not available.

> ℹ️ The package installs a single command called **`spf`**, not `superfile` —
> that is upstream's own naming. Upstream ships no man page or shell
> completions; run `spf --help` for the command reference and `spf path-list`
> to print the configuration and data directory paths.

superfile has no hard dependencies (it is a statically linked Go binary), but a
few optional tools unlock extra features: `xdg-utils` to open files with your
desktop's default application, `zoxide` for the jump panel, `ffmpeg` and
`poppler-utils` for video and PDF previews, `libimage-exiftool-perl` for
extended metadata, and `xclip` or `wl-clipboard` for clipboard integration.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the superfile source code, see
[superfile](https://github.com/yorukot/superfile/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-superfile-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-superfile-in-ubuntu.html)

### The Debian way

> ⚠️ **From 1 October 2026, apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/superfile-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y superfile
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/superfile-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <superfile_version> <build_version> <architecture>
# Example: ./build.sh 1.6.0 1 arm64
```

### Build for all architectures
```sh
./build.sh <superfile_version> <build_version> all
# Example: ./build.sh 1.6.0 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to superfile. This repo is only for _unofficial_ Debian packaging.
