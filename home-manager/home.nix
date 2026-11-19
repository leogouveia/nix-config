{ ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/ia.nix
    ./modules/input.nix
    ./modules/langs.nix
    ./modules/gnome.nix
    ./modules/terminals.nix
    ./modules/fonts.nix
    ./modules/browsers.nix
    ./modules/apps.nix
    ./modules/multimedia.nix
    ./modules/flatpak.nix
    ./modules/claude-statusline.nix
  ];

  home = {
    username = "leogouveia";
    homeDirectory = "/home/leogouveia";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
