{ pkgs, inputs, ... }:

{
  # Emuladores de terminal
  home.packages = with pkgs; [
    ptyxis
    inputs.ghostty-pkgs.packages.${pkgs.system}.default
  ];

  home.shellAliases = {
    ez = "SUDO_EDITOR='zeditor --wait' sudoedit";
    ec = "SUDO_EDITOR='code --wait' sudoedit";

    # ── NixOS ─────────────────────────────────────
    nixcheck = "sudo nix-instantiate '<nixpkgs/nixos>' -A config.system.build.toplevel.drvPath --eval-only";
    nixbuild = "sudo nixos-rebuild build";
    nixswitch = "sudo nixos-rebuild switch";
    nixboot = "sudo nixos-rebuild boot";
    nixupdate = "sudo nix-channel --update && sudo nixos-rebuild switch";

    # ── Home Manager ──────────────────────────────
    # Sintaxe de um arquivo
    hmsyntax = "nix-instantiate --parse ~/nix-config/home-manager/home.nix > /dev/null";

    # Avaliação completa, sem build
    hmcheck = "nix eval --raw ~/nix-config#homeConfigurations.leogouveia.activationPackage.drvPath";

    hmbuild = "home-manager build --flake ~/nix-config";
    hmswitch = "home-manager switch --flake ~/nix-config";

    hmgens = "home-manager generations";
    hmnews = "home-manager news";

    # ── Manutenção ────────────────────────────────
    nixdiff = "nvd diff /run/current-system result";
    nixgc = "nix-collect-garbage";
    nixgcsys = "sudo nix-collect-garbage";

    # ── Flakes ───────────────────────────────────────
    flakeupdate = "nix flake update --flake ~/nix-config";
    flakeshow = "nix flake show ~/nix-config";
    flakemetadata = "nix flake metadata ~/nix-config";

    # Flatpak
    fpupdate = "flatpak update --user";

  };

  # Zsh
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };

    antidote = {
      enable = true;

      plugins = [
        # Completions
        "zsh-users/zsh-completions"

        # Integração com Git
        "ohmyzsh/ohmyzsh path:plugins/git"

        # Sugestões e highlighting
        "zsh-users/zsh-autosuggestions"
        "zdharma-continuum/fast-syntax-highlighting"

        # Prompt
        "romkatv/powerlevel10k"
      ];
    };

    initContent = ''
      # Configuração personalizada do Zsh
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  # Fish
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  # ghostty settings
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      # Aparência
      theme = "Catppuccin Mocha";
      window-theme = "system";

      # Tipografia
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12.5;

      # Janela
      window-padding-x = 12;
      window-padding-y = 10;
      window-padding-balance = true;
      # gtk-titlebar-style = "tabs";
      # gtk-toolbar-style = "flat";

      # Transparência
      background-opacity = 0.98;
      background-blur = true;

      # Cursor
      cursor-style = "bar";
      cursor-style-blink = false;

      # Integração
      shell-integration = "fish";

      # Histórico
      scrollback-limit = 10000000;
    };
  };
}
