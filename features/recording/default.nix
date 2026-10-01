{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.recording;
in {
  options.recording = {
    framerate = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = "Frames per second to record at.";
    };

    audio = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["default_output"];
      example = ["default_output" "default_input"];
      description = ''
        Audio sources to mix in, as gpu-screen-recorder `-a` values:
        `default_output`, `default_input`, `device:name` or `app:name`.
        Set to `[]` to record silently. `gpu-screen-recorder
        --list-audio-devices` lists what is available.
      '';
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/Videos";
      description = ''
        Directory recordings are written to, created on demand. Expanded by the
        shell at record time, so it may reference variables such as `$HOME`.
      '';
    };

    keyOverlay = {
      anchor = lib.mkOption {
        type = lib.types.listOf (lib.types.enum ["top" "bottom" "left" "right"]);
        default = ["bottom" "right"];
        description = ''
          Screen edges to anchor the overlay to. wshowkeys ORs these together,
          so two perpendicular edges pin it to that corner.
        '';
      };

      margin = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 100;
        description = "Gap in pixels between the overlay and the anchored edges.";
      };

      timeout = lib.mkOption {
        type = lib.types.ints.positive;
        default = 1000;
        description = ''
          How long a keypress stays on screen, in **milliseconds** (wshowkeys
          compares this against an elapsed-ms counter; its own default of 200 is
          a fifth of a second).
        '';
      };
    };
  };

  config.leaderMenu = let
    record = lib.getExe (import ./package.nix {
      inherit pkgs lib;
      inherit (cfg) framerate audio directory;
      mango = config.package;
    });
    keyOverlay = lib.getExe (import ./overlay.nix {
      inherit pkgs lib;
      inherit (cfg.keyOverlay) anchor margin timeout;
    });
  in [
    {
      key = "r";
      desc = "Record";
      submenu = [
        {
          key = "s";
          desc = "Screen (toggle)";
          cmd = "${record} screen";
        }
        {
          key = "a";
          desc = "Area (toggle)";
          cmd = "${record} region";
        }
        {
          key = "k";
          desc = "Keys overlay (toggle)";
          cmd = keyOverlay;
        }
      ];
    }
  ];
}
