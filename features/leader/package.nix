{
  pkgs,
  lib,
  mango,
  menu,
}: let
  # Lowercase before uppercase for the same letter, so a menu holding both `s`
  # and `S` reads as "s, S" rather than being split apart by ASCII ordering.
  byKey = a: b: let
    la = lib.toLower a.key;
    lb = lib.toLower b.key;
  in
    if la != lb
    then la < lb
    else a.key > b.key;

  # The submodule type fills in `cmd = null` / `submenu = []` for whichever
  # branch an entry doesn't use; wlr-which-key rejects both, so drop them.
  # Sorting here makes the menu independent of module merge order.
  normalize = entries:
    map (
      entry:
        {inherit (entry) key desc;}
        // lib.optionalAttrs (entry.cmd != null) {inherit (entry) cmd;}
        // lib.optionalAttrs (entry.submenu != []) {submenu = normalize entry.submenu;}
    ) (lib.sort byKey entries);

  whichKeyConfig =
    (pkgs.formats.yaml {}).generate "mango-which-key.yaml"
    {menu = normalize menu;};
in
  pkgs.writeShellScriptBin "mango-leader" ''
    export PATH=${mango}/bin:$PATH
    # Only one menu at a time. `9>&-` closes the lock fd in the child, or
    # wlr-which-key would pass it to every command it launches and a long-lived
    # one would hold the lock. No `exec`: this shell must stay alive to own fd 9.
    exec 9>''${XDG_RUNTIME_DIR:-/tmp}/mango-leader.lock
    ${pkgs.util-linux}/bin/flock -n 9 || exit 0
    ${pkgs.wlr-which-key}/bin/wlr-which-key ${whichKeyConfig} 9>&-
  ''
