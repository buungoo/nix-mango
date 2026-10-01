inputs: {
  lib,
  pkgs,
  wlib,
  ...
}: let
  vicinae = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [
    wlib.wrapperModules.mangowc
    ./features/leader
    ./features/recording
  ];

  config.package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

  # Mango config
  config.sourcedFiles = [
    ./config/appearance.conf
    ./config/animations.conf
    ./config/behavior.conf
    ./config/layouts/scroller.conf
    ./config/input.conf
    ./config/binds.conf
  ];

  # Startup components, pinned to exact binaries and shipped with the config
  config.autostart_sh = ''
    ${lib.getExe pkgs.waybar} &
    ${lib.getExe vicinae} server &
  '';

  # DE utilities on mango's PATH
  config.runtimePkgs = [
    pkgs.waybar
    vicinae
  ];
}
