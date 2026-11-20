{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  vscodePkgs = import inputs.vscode-pkgs {
    inherit system;
    config.allowUnfree = true;
  };

  vscodiumPkgs = import inputs.vscodium-pkgs {
    inherit system;
  };

  zedPkgs = import inputs.zed-pkgs {
    inherit system;
  };
in
{
  programs.vscode = {
    enable = true;
    package = vscodePkgs.vscode;
  };

  # Não adicionar o VSCodium ao ambiente combinado
  programs.vscodium.enable = false;

  # Disponibilizar o VSCodium pelo menu do GNOME
  xdg.desktopEntries.vscodium = {
    name = "VSCodium";
    genericName = "Editor de código";
    exec = "${vscodiumPkgs.vscodium}/bin/codium %F";
    icon = "vscodium";
    terminal = false;
    categories = [
      "Development"
      "IDE"
      "TextEditor"
    ];
  };

  programs.zed-editor = {
    enable = true;
    package = zedPkgs.zed-editor;

    extensions = [
      "nix"
      "lua"
      "nvim-nightfox"
      "material-icon-theme"
      "catppuccin-icons"
    ];

    extraPackages = with pkgs; [
      nixd
      nixfmt
      ruff
    ];

    userSettings = import ./zed-settings.nix { inherit pkgs zedPkgs; };
  };
}
