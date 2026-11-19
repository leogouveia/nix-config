{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    tree
    wl-clipboard
    nvd
    _7zz
    btop
    duf
    fastfetch
    glances
    micro
    pv
    ripgrep
    tree
    unrar
    unzip
    watchexec
    wget
    yadm
    papirus-icon-theme
  ];
}
