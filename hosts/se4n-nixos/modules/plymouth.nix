{ pkgs, ... }:

let
  selectedTheme = "colorful_sliced";
in
{
  boot = {

    plymouth = {
      enable = true;
      theme = selectedTheme;
      # extraConfig = ''
      #   [Daemon]
      #   DeviceScale=an-integer-scaling-factor
      # '';
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ selectedTheme ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
