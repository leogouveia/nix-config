{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    font-manager
    gcolor3
    gpick
    libreoffice
    hunspellDicts.pt_BR
    meld
    pavucontrol
    resources
    file-roller
    rclone
    insync
    gnome-tweaks
    inputs.artcraft-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.photocraft
    distrobox
  ];
}
