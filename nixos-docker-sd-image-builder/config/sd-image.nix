{ lib, pkgs, config, ... }: {
  imports = [
    ./rpi4
    ./postgresql.nix
    ./ollama.nix
  ];


  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;
  networking = {
    hostName = "nixos-rpi4";
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5432 11434 ]; # PostgreSQL and Ollama ports
    };
  };
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;  # Use LightDM instead of GDM
      autoLogin = {
        enable = true;
        user = "alice";
      };
    };
    desktopManager = {
      xfce.enable = true;  # Use XFCE instead of GNOME
    };
    videoDrivers = [ "modesetting" ];
  };
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    ollama
    postgresql
    cifs-utils
    # Add these packages for better graphics support
    glxinfo
    mesa
    mesa-demos
    libraspberrypi
    raspberrypi-eeprom
  ];
}
