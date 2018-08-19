{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "dhruv-io";
  buildInputs = [
    nodejs-9_x
  ];
  shellHook = ''
    source ~/.bashrc
    [ -f tmp/env ] && source tmp/env
    npm install
  '';
}
