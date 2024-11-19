#!/bin/bash

# Create the SD card image
nix-build '<nixpkgs/nixos>' \
  -A config.system.build.sdImage \
  -I nixos-config=raspberry-pi4.nix \
  --argstr system aarch64-linux \
  --option sandbox false \
  --show-trace

# The image will be created in result/sd-image/nixos-sd-image-*-aarch64-linux.img