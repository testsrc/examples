#!/usr/bin/env bash
# Install one player on GitHub's ubuntu-24.04 runner, as the testsrc/run README says.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
case "$1" in
  ffmpeg)    pkgs="ffmpeg" ;;
  libvlc)    pkgs="libvlc5 vlc-plugin-base" ;;
  gstreamer) pkgs="gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav" ;;
  mpv)       echo "jackd2 jackd/tweak_rt_limits boolean false" | sudo debconf-set-selections
             pkgs="libmpv2 jackd2" ;;
  *) echo "unknown player $1"; exit 2 ;;
esac
sudo apt-get update -qq
sudo apt-get install -y -qq --no-install-recommends $pkgs > /dev/null
dpkg-query -W -f='${Package} ${Version}\n' $pkgs
