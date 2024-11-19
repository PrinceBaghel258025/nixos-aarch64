{ config, pkgs, modulesPath, lib, ... }:
{

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./postgresql.nix
    ./ollama.nix
  ];
  # boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Adjust as necessary

  # boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  
  services.xserver.enable = true;


  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.gnome.enable = true;


  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    # ntfs-3g
    cifs-utils
    cowsay
    lolcat
    postgresql
    ollama
  ];
  networking.firewall.enable = true;
  networking.wireless.enable = false;
  # Enable networking (useful for PostgreSQL remote connections)
  networking.firewall.allowedTCPPorts = [ 5432 11434 ];
  system.stateVersion = "24.05";
}
