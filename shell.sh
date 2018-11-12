#! /usr/bin/env bash

NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/14f9ee66e63077539252f8b4550049381a082518.tar.gz nix-shell "$@"
