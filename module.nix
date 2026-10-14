inputs: {
  lib,
  pkgs,
  wlib,
  ...
}: {
  imports = [
    wlib.wrapperModules.mangowc
    ./features/leader
    ./features/recording
  ];

  config.package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

  # Mango config
  config.settings.bind = [
    "SUPER,d,spawn,${lib.getExe pkgs.fuzzel}"
  ];

  # These files are copied into the Nix store; edits require a rebuild.
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
  '';

  # DE utilities on mango's PATH
  config.runtimePkgs = [
    pkgs.waybar
  ];
}
