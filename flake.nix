{
  description = "Home Manager - Leonardo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";

    chatgpt-desktop.url = "github:csoftware-arigpt/nixos-chatgpt";

    claude-desktop.url = "github:danielbodart/claude-desktop";

    zed-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    vscode-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    vscodium-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    unstable-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    artcraft-pkgs.url = "github:Hy4ri/artcraft-flake";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty-pkgs.url = "github:ghostty-org/ghostty";

    gspotify-lab = {
      url = "github:leogouveia/gspotify/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-updater = {
      url = "github:leogouveia/nix-updater";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      android-nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        android_sdk.accept_license = true;
      };
    in
    {
      homeConfigurations.leogouveia = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs;
        };

        modules = [
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
          ./home-manager/home.nix
        ];
      };
    };
}
