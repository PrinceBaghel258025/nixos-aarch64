{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"}/raspberry-pi/4"
    ./postgresql.nix
    ./ollama.nix
  ];
  boot.kernelModules = [ "sun4i-drm" "fbdev" ];

  # SD image specific configuration
  sdImage = {
    imageBaseName = "nixos-rpi4";
    compressImage = false;
    firmwareSize = 128;
    rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
  };

  # File systems configuration for Raspberry Pi
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
  };

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Basic system configuration
  networking = {
    hostName = "nixos-rpi4";
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5432 11434 ]; # PostgreSQL and Ollama ports
    };
  };


  # Enable X11 and GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # User configuration
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    initialPassword = "test";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    cifs-utils
    cowsay
    lolcat
    postgresql
    ollama
  ];

  # Enable SSH for remote administration
  services.openssh.enable = true;


  system.stateVersion = "24.05";
} 