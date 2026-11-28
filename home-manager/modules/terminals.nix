{ pkgs, inputs, ... }:

let
  ghosttyConfigMime =
    pkgs.runCommand "ghostty-config-mime"
      {
        nativeBuildInputs = [ pkgs.shared-mime-info ];
      }
      ''
        mkdir -p "$out/share/mime/packages" "$out/share/applications"
        cat > "$out/share/mime/packages/ghostty-config.xml" <<'EOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="text/x-ghostty-config">
            <comment>Ghostty configuration</comment>
            <sub-class-of type="text/plain"/>
            <glob pattern="config.ghostty" weight="80"/>
          </mime-type>
        </mime-info>
        EOF
        XDG_DATA_DIRS="$out/share" update-mime-database "$out/share/mime"

        cat > "$out/share/applications/mimeapps.list" <<'EOF'
        [Default Applications]
        text/x-ghostty-config=dev.zed.Zed.desktop;
        EOF
      '';
in
{
  # Emuladores de terminal
  home.packages = [ pkgs.ptyxis ];

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

    # Atualiza a grade de aplicativos do GNOME
    appsrefresh = "mkdir -p ~/.local/share/applications && touch ~/.local/share/applications/.refresh.desktop && rm ~/.local/share/applications/.refresh.desktop";

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

    functions = {
      boxcreate = ''
        if test (count $argv) -ne 2
          echo "Uso: boxcreate <nome> <imagem>"
          return 1
        end

        mkdir -p "$HOME/Distrobox/$argv[1]"

        distrobox create \
          --name "$argv[1]" \
          --image "$argv[2]" \
          --home "$HOME/Distrobox/$argv[1]"
      '';
    };
  };

  # Registra apenas config.ghostty, sem alterar o editor padrão de texto.
  xdg.systemDirs.data = [ "${ghosttyConfigMime}/share" ];

  # O yadm gerencia ~/.config/ghostty/config.ghostty.
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
