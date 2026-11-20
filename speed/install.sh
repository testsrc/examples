#!/usr/bin/env bash
# Install one player in the job's Arch Linux container, from the Arch Linux Archive at the date testsrc's own runner
# image pins (versions.json → runner): libvlc 3.0.24, FFmpeg 9.0.2, GStreamer 1.28.8, mpv 0.41.0. Ubuntu 24.04's
# packages are older (its GStreamer 1.24 can't open a local HLS or DASH playlist), so they would test the setup.
set -euo pipefail
case "$1" in
  libvlc)    pkgs="libvlc vlc-plugins-base vlc-plugins-extra"; ver=libvlc ;;
  ffmpeg)    pkgs="ffmpeg"; ver=ffmpeg ;;
  gstreamer) pkgs="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"; ver=gstreamer ;;
  mpv)       pkgs="mpv jack2"; ver=mpv ;;
  *) echo "unknown player $1"; exit 2 ;;
esac
echo "Server=https://archive.archlinux.org/repos/${ARCH_DATE}/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
pacman -Syyuu --noconfirm --noprogressbar > /dev/null
# the tools run-shard.sh and seal.sh use, then the player
pacman -S --noconfirm --needed --noprogressbar curl jq ca-certificates openssl tar gzip gawk $pkgs > /dev/null
pacman -Q $ver
