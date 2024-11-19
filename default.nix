# default.nix
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; system = builtins.currentSystem; };
in
{
  # hello = pkgs.callPackage ./hello.nix { };
  # icat = pkgs.callPackage ./icat.nix { };
  # hmi = pkgs.callPackage ./hmi.nix { };
  # panomic = pkgs.callPackage ./panomic.nix { };
  zenoh = pkgs.callPackage ./zenoh.nix { };
}
