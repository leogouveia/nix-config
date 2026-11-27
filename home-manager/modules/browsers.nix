{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    ungoogled-chromium
    (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      nativeMessagingHosts = [
        pkgs._1password-gui
      ];
    })
  ];

  # O 1Password não grava sua própria entrada de autostart quando
  # empacotado via Nix, então criamos a entrada XDG manualmente.
  xdg.configFile."autostart/1password-silent.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=1Password
    Comment=Inicia o 1Password em segundo plano
    Exec=${pkgs._1password-gui}/bin/1password --silent
    Icon=1password
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';

}
