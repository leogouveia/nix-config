{
  pkgs,
  inputs,
  unstablePkgs,
  ...
}:

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

  claudeAcp = pkgs.writeShellScriptBin "claude-agent-acp" ''
    export CLAUDE_CODE_EXECUTABLE="${unstablePkgs.claude-code}/bin/claude"
    exec "${pkgs.claude-agent-acp}/bin/claude-agent-acp" "$@"
  '';
in
{
  programs.vscode = {
    enable = true;
    package = vscodePkgs.vscode;
    # Preferências e atalhos do perfil padrão são gerenciados pelo yadm.
    profiles.default.extensions = import ./vscode-extensions.nix vscodePkgs.vscode-extensions;
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

    # O yadm gerencia settings.json, incluindo auto_install_extensions.
    extraPackages = with pkgs; [
      nixd
      nixfmt
      ruff
      stylua
      opencode
      zedPkgs.codex-acp
      claudeAcp
    ];
  };
}
