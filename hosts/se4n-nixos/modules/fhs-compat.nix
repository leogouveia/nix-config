{ pkgs, ... }:

let
  mountOptions = [
    "ro"
    "x-gvfs-hide"
    "resolve-symlinks"
  ];

  mkMount = device: {
    inherit device;
    fsType = "fuse.bindfs";
    options = mountOptions;
  };
in
{
  system.fsPackages = [ pkgs.bindfs ];

  fileSystems = {
    "/usr/share/fonts" = mkMount "/run/current-system/sw/share/X11/fonts";

    "/usr/share/icons" = mkMount "/run/current-system/sw/share/icons";

    "/usr/share/themes" = mkMount "/run/current-system/sw/share/themes";
  };
}
