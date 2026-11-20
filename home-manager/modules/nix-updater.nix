{ pkgs, inputs, ... }:

let
  nix-updater = inputs.nix-updater.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ nix-updater ];

  # Inicia junto da sessão gráfica — o indicador de bandeja depende do
  # appindicator do GNOME (ver gnome.nix), que só existe com o shell no ar.
  #
  # O Exec do .desktop empacotado é relativo ("nix-updater"), o que depende
  # do PATH que o gdm entrega à sessão; trocar pelo caminho absoluto do
  # store remove essa dependência. O resto do arquivo vem do pacote, então
  # ícone e categorias continuam acompanhando quem o gera.
  xdg.configFile."autostart/io.Astal.nix-updater.desktop".source =
    pkgs.runCommand "nix-updater-autostart.desktop" { } ''
      substitute \
        ${nix-updater}/share/applications/io.Astal.nix-updater.desktop \
        $out \
        --replace-fail 'Exec=nix-updater' 'Exec=${nix-updater}/bin/nix-updater'
    '';
}
