{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "dhruv-io";
  buildInputs = [
    nodejs-8_x
    elmPackages.elm
  ];
  shellHook = ''
    source ~/.bashrc
    [ -f tmp/env ] && source tmp/env
    npm install
    elm package install
  '';
}
