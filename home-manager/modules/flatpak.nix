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
      "be.alexandervanhee.gradia"
      "io.github.tobagin.karere"

      # Multimídia
      "io.github.celluloid_player.Celluloid"
      "de.haeckerfelix.Fragments"
      "com.spotify.Client"

      # Gerenciamento
      "com.github.tchx84.Flatseal"
      "com.ranfdev.DistroShelf"
      "org.gnome.World.PikaBackup"

    ];

    uninstallUnmanaged = false;

    overrides.settings."com.spotify.Client" = {
      Context = {
        sockets = [
          "!wayland"
          "x11"
        ];
        unset-environment = [
          "WAYLAND_DISPLAY"
          "XDG_SESSION_TYPE"
        ];
      };

      Environment = {
        WAYLAND_DISPLAY = "";
        XDG_SESSION_TYPE = "";
      };
    };

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
