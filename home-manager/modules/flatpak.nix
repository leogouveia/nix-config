{ config, ... }:

{

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  services.flatpak = {
    enable = true;

    packages = [
      # Produtividade
      "net.donnybeelo.Convey"
      "org.onlyoffice.desktopeditors"
      "com.github.marktext.marktext"
      "com.rtosta.zapzap"

      # Multimídia
      "io.github.celluloid_player.Celluloid"
      "de.haeckerfelix.Fragments"
      "com.spotify.Client"


      # Gerenciamento
      "com.github.tchx84.Flatseal"


    ];

    uninstallUnmanaged = false;

    overrides.settings."com.spotify.Client".Context.sockets = [
      "!wayland"
      "x11"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
