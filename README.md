# testsrc examples

[![libvlc](https://github.com/testsrc/examples/actions/workflows/libvlc.yml/badge.svg)](https://github.com/testsrc/examples/actions/workflows/libvlc.yml)
[![ffmpeg](https://github.com/testsrc/examples/actions/workflows/ffmpeg.yml/badge.svg)](https://github.com/testsrc/examples/actions/workflows/ffmpeg.yml)
[![your player](https://github.com/testsrc/examples/actions/workflows/your-player.yml/badge.svg)](https://github.com/testsrc/examples/actions/workflows/your-player.yml)

Working GitHub Actions workflows that play [testsrc](https://testsrc.com) test files through a player on every push
and pull request, with [`testsrc/run`](https://github.com/testsrc/run). Each runs the 10 starter cases in about two
minutes. Copy the one that matches your player.

| Workflow | For | What testsrc checks |
| --- | --- | --- |
| [`libvlc.yml`](.github/workflows/libvlc.yml) | An app that plays through libvlc | Every frame, its time, orientation, aspect and colour; the audio against its beeps |
| [`ffmpeg.yml`](.github/workflows/ffmpeg.yml) | A player built on FFmpeg | The same, through `ffmpeg` and `ffprobe` |
| [`your-player.yml`](.github/workflows/your-player.yml) | Any player with a command line | What the process does: exit code, crash, hang, time |

GStreamer and mpv work the same way (`player: gstreamer`, `player: mpv`): see the
[action's README](https://github.com/testsrc/run#readme).

## Use one in your repo

1. Get a token: sign in at [testsrc.com/account](https://testsrc.com/account) with GitHub. Companies start a free
   evaluation there; open-source projects [ask for a free token](https://testsrc.com/#contact).
2. Save it as a repository secret named `TESTSRC_TOKEN` (Settings > Secrets and variables > Actions).
3. Copy the workflow to `.github/workflows/testsrc.yml` in your repo, and replace the install step with how you build
   your player.
4. Push. The job summary lists each case that failed and why; `testsrc-results/` holds `results.json`, a JUnit
   report and each case's events.

On the first run, the action writes `testsrc.lock`, which pins the snapshot of test files: commit it, so every run
plays the same bytes. Pull requests from forks get no secrets, so there the action skips itself.

## With an AI assistant

Paste this into Claude Code, Cursor, Codex or another coding assistant, in your player's repo:

> Add testsrc to this repo's CI. Read https://github.com/testsrc/examples and pick the workflow that matches how
> this project plays media (libvlc, FFmpeg, or the command-line player). Copy it to .github/workflows/testsrc.yml,
> replace the install step with this project's build, and tell me to add the TESTSRC_TOKEN secret.

## This repository

- The workflows run on pushes to `main`, on pull requests and every Monday, with the starter set only.
- `player/play.sh` stands in for your player in `your-player.yml`: it decodes each file to the end with FFmpeg.
- More inputs (case sets, `exclude`, snapshots, `report-only`): [testsrc/run](https://github.com/testsrc/run#readme).
  The API: [testsrc.com/docs/api](https://testsrc.com/docs/api).
