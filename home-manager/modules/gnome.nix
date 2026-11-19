{ pkgs, ... }:

{
  programs.gnome-shell = {
    enable = true;

    extensions = with pkgs.gnomeExtensions; [
      { package = appindicator; }
      { package = blur-my-shell; }
      { package = dash-to-dock; }
      { package = emoji-copy; }
      { package = gspotify; }
      { package = kimpanel; }
      { package = panel-date-format; }
      { package = tiling-assistant; }
      { package = user-themes; }
    ];
  };

  gtk.enable = true;

  # Tema GTK3/GTK4 — adw-gtk3 replica o visual do libadwaita em apps GTK3
  gtk.theme = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };

  # Ícones
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/shell" = {
        always-show-log-out = true;
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "Print" "<Super><Shift>s" ];
      };

      "org/gnome/desktop/interface" = {
          accent-color = "purple";
          icon-theme = "Papirus";
          gtk-theme = "adw-gtk3-dark";
          color-scheme = "prefer-dark";
        };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,close";
      };

      # Formato de data utilizado no CachyOS
      "org/gnome/shell/extensions/panel-date-format" = {
        format = "%A, %d/%m/%Y • %H:%M";
      };

      # Terminal Ptyxis
      "org/gnome/Ptyxis" = {
        use-system-font = false;
        font-name = "MesloLGMDZ Nerd Font 12";
      };
    };
  };
}
