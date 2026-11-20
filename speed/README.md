# Speed test (temporary)

How long GitHub Actions takes to play the whole testsrc catalog through libvlc, FFmpeg, GStreamer and mpv with
`testsrc/run@v1`'s own script, sharded across jobs. Results aren't public: nothing goes to the job summary,
annotations or log, and each shard's results are encrypted with `public-key.pem` before upload.
