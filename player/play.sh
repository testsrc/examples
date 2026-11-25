#!/bin/sh
# A stand-in for your player: decodes the file's video and audio to the end, shows nothing, and exits non-zero when
# FFmpeg can't. testsrc runs it once per case (your-player.yml) and judges what the process does.
exec ffmpeg -nostdin -hide_banner -loglevel error -i "$1" -f null -
