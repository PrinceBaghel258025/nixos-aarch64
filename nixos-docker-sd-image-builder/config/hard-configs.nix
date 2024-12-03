/*
*Hardware configuration file for Raspberry Pi.
*import this file from the configuration.nix
*To do: add GPIO to the user's list in configuration.nix
*
*/

{ config, pkgs, lib, ... }:

{
imports = [
  "${fetchTarball "https://github.com/NixOS/nixos-hardware/tarball/master"}/raspberry-pi/4"
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

#  comment this to use gnome and uncomment it to use sddm
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

}
