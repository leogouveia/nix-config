{
  config,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  graphicsLibraries =
    pkgs.lib.makeLibraryPath [
      pkgs.libglvnd
      pkgs.vulkan-loader
    ]
    + ":/run/opengl-driver/lib";

  androidSdk = inputs.android-nixpkgs.sdk.${system} (
    sdk: with sdk; [
      cmdline-tools-latest
      platform-tools
      build-tools-36-0-0
      platforms-android-36

      (emulator.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
          pkgs.makeWrapper
        ];

        postFixup = (old.postFixup or "") + ''
          wrapProgram "$out/emulator" \
            --prefix LD_LIBRARY_PATH : "${graphicsLibraries}" \
            --set VK_ICD_FILENAMES \
              "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
        '';
      }))
      
      

      system-images-android-36-google-apis-playstore-x86-64
    ]
  );

  sdkPath = "${androidSdk}/share/android-sdk";
  androidUserHome = "${config.xdg.configHome}/.android";
in
{
  home.packages = [
    pkgs.android-studio
    androidSdk
  ];

  home.sessionVariables = {
    ANDROID_HOME = sdkPath;
    ANDROID_SDK_ROOT = sdkPath;
    ANDROID_USER_HOME = androidUserHome;
    ANDROID_AVD_HOME = "${androidUserHome}/avd";
  };

  home.sessionPath = [
    "${sdkPath}/emulator"
    "${sdkPath}/platform-tools"
    "${sdkPath}/cmdline-tools/latest/bin"
  ];
}
