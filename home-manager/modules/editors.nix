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

    extensions = [ "nix" ];

    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];

    userSettings = {
      agent_servers."Claude (Nix)" = {
        type = "custom";
        command = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
        args = [ ];
        env = {
          CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";
        };
      };

      languages.Nix = {
        # Somente o nixd como LSP
        language_servers = [
          "nixd"
          "!nil"
        ];

        lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";

        # Formatação automática ao salvar
        format_on_save = "on";

        formatter.external = {
          command = "${pkgs.nixfmt}/bin/nixfmt";
          arguments = [ ];
        };
      };

      # Usa explicitamente o nixd do NixOS
      lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
    };
  };
}
