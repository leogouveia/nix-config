{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # Não adicionar o pacote ao ambiente combinado
  programs.vscodium.enable = false;

  # Disponibilizar o VSCodium pelo menu do GNOME
  xdg.desktopEntries.vscodium = {
    name = "VSCodium";
    genericName = "Editor de código";
    exec = "${pkgs.vscodium}/bin/codium %F";
    icon = "vscodium";
    terminal = false;
    categories = [ "Development" "IDE" "TextEditor" ];
  };

  programs.zed-editor = {
    enable= true;

    extensions = [ "nix" ];

    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];

    userSettings = {
      languages.Nix = {

        # Somente o nixd como LSP
        language_servers = [ "nixd" "!nil" ];

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
