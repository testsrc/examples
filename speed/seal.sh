#!/usr/bin/env bash
# Encrypt private/ for upload: a fresh AES-256 key per shard, the key sealed with speed/public-key.pem (RSA-OAEP).
# Only the holder of the private key (not in this repo) can read the artifact.
set -euo pipefail
mkdir -p sealed
tar -czf sealed/results.tgz --exclude='private/out/events' private 2>/dev/null || tar -czf sealed/results.tgz private
openssl rand -out sealed/key.bin 32
openssl enc -aes-256-cbc -pbkdf2 -salt -in sealed/results.tgz -out sealed/results.tgz.enc -pass file:sealed/key.bin
openssl pkeyutl -encrypt -pubin -inkey speed/public-key.pem -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 -in sealed/key.bin -out sealed/key.enc
rm -f sealed/key.bin sealed/results.tgz
ls -l sealed | awk 'NR>1 {print $5, $9}'
