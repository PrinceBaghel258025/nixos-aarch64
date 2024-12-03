{ lib, pkgs, config, ... }:
 let
  hostname = "panomic";
  user = "panomic";
  password = "qwerty";

  timeZone = "America/New_York";
  defaultLocale = "en_US.UTF-8";
in {
  imports = [
    ./rpi4
    ./postgresql.nix
    ./ollama.nix
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/tarball/master"}/raspberry-pi/4"
  ];

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  boot = {
    kernelModules = [ "i2c-dev" "i2c-bcm2835" ];
    kernelParams = [
      "console=ttyAMA1,115200"
      "dtparam=i2c_arm=on"
      "dtoverlay=i2c1"
    ];
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    raspberry-pi."4".touch-ft5406.enable = true;
    i2c.enable=true;
    deviceTree = {
      enable = true;
      filter = lib.mkDefault"bcm2711-rpi-*.dtb"; # "*rpi-4-*.dtb";
        overlays = [
        {
          name = "i2c1";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";

              fragment@0 {
                target-path = "/soc/i2c@7e804000";
                __overlay__ {
                  status = "okay";
                  clock-frequency = <100000>;
                };
              };

              fragment@1 {
                target = <&gpio>;
                __overlay__ {
                  i2c1_pins: i2c1_pins {
                    brcm,pins = <2 3>; // GPIO pins for I2C1
                    brcm,function = <4>; // ALT0 function
                  };
                };
              };
            };
          '';
        }
      ];
    };
  };
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  console.enable = false;
  hardware.raspberry-pi."4".dwc2.enable =true;
  hardware.enableRedistributableFirmware = true;

  users.groups.gpio = {};
  users.groups.i2c = {};

 services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';

  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = user;
      };
    };
    desktopManager.gnome.enable = true;
  };
  
  # services.displayManager.autoLogin = {
  #     enable = true;
  #     user = user;
  # };

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
    # enable = true;
    # displayManager = {
    #   lightdm.enable = true;  # Use LightDM instead of GDM
    #   autoLogin = {
    #     enable = true;
    #     user = "alice";
    #   };
    # };
    # desktopManager = {
    #   xfce.enable = true;  # Use XFCE instead of GNOME
    # };
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
    firefox
    vim
    pkgs.python312
    pkgs.python312Packages.rpi-gpio
  ];
}
