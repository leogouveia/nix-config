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
}
