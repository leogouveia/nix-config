{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  androidSdk = inputs.android-nixpkgs.sdk.${system} (
    sdk: with sdk; [
      cmdline-tools-latest
      platform-tools
      build-tools-36-0-0
      platforms-android-36

      emulator
      system-images-android-36-google-apis-playstore-x86-64
    ]
  );
  sdkPath = "${androidSdk}/share/android-sdk";
in
{
  home.packages = with pkgs; [
    android-studio
    android-tools
    androidSdk
  ];

  home.sessionVariables = {
    ANDROID_HOME = sdkPath;
    ANDROID_SDK_ROOT = sdkPath;
  };

  home.sessionPath = [
    "${sdkPath}/emulator"
    "${sdkPath}/platform-tools"
    "${sdkPath}/cmdline-tools/latest/bin"
  ];
}
