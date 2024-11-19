{ pkgs ? import <nixpkgs> {} }:

let
  nixos-hardware = builtins.fetchGit {
    url = "https://github.com/NixOS/nixos-hardware.git";
    rev = "d4ea64f2063820120c05f6ba93ee02e6d4671d6b"; # Use a specific revision
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    nixos-generators
  ];

  NIX_PATH = "nixos-hardware=${nixos-hardware}:nixpkgs=${pkgs.path}";
} 