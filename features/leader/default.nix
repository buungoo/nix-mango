{
  config,
  lib,
  pkgs,
  ...
}: let
  # A wlr-which-key node: `key` + `desc`, then either `cmd` (a leaf) or
  # `submenu` (a branch). Recursive, so nesting is unbounded.
  menuEntry = lib.types.submodule {
    options = {
      key = lib.mkOption {
        type = lib.types.str;
        example = "s";
        description = "Key that selects this entry. Case sensitive.";
      };
      desc = lib.mkOption {
        type = lib.types.str;
        example = "Screen";
        description = "Label shown in the menu.";
      };
      cmd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "mmsg dispatch setlayout,tile";
        description = ''
          Shell command to run when this entry is selected. `mmsg` is on PATH.
          Mutually exclusive with `submenu`.
        '';
      };
      submenu = lib.mkOption {
        type = lib.types.listOf menuEntry;
        default = [];
        description = ''
          Nested entries, opened when this entry is selected.
          Mutually exclusive with `cmd`.
        '';
      };
    };
  };
in {
  imports = [./menu.nix];

  options.leaderKey = lib.mkOption {
    type = lib.types.str;
    default = "ALT,code:64";
    example = "SUPER,space";
    description = ''
      Mango bind prefix (`mods,key`) that opens the leader menu. Registered as a
      `bindr`, so it fires on release — that is what makes a bare modifier such
      as left Alt (`code:64`) usable as the trigger.
    '';
  };

  options.leaderMenu = lib.mkOption {
    type = lib.types.listOf menuEntry;
    default = [];
    description = ''
      Leader menu contents. Every module's definitions are concatenated and then
      sorted by `key`, so a re-wrapper adds entries just by declaring its own
      `leaderMenu` list. Use `lib.mkForce []` to drop the defaults in ./menu.nix.
    '';
  };

  config.settings.bindr = let
    mangoLeader = import ./package.nix {
      inherit pkgs lib;
      mango = config.package;
      menu = config.leaderMenu;
    };
  in [
    "${config.leaderKey},spawn,${lib.getExe mangoLeader}"
  ];
}
