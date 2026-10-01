{
  pkgs,
  lib,
  anchor,
  margin,
  timeout,
}:
# On-screen keypress overlay, for recordings that demonstrate keybindings.
#
# Runs the /run/wrappers/bin copy, not the store one: wshowkeys reads
# /dev/input, so it needs setuid, which the store cannot carry. The store binary
# checks euid first and refuses everything, even `--help`.
pkgs.writeShellScriptBin "mango-keyoverlay" ''
  set -eu

  wshowkeys=/run/wrappers/bin/wshowkeys
  if [ ! -u "$wshowkeys" ]; then
    echo "mango-keyoverlay: $wshowkeys is missing or not setuid" >&2
    exit 1
  fi

  # A second press stops it. "wshowkeys" fits in comm's 15 chars, so -x matches
  # and no pidfile is needed.
  if ${pkgs.procps}/bin/pkill -x wshowkeys; then
    exit 0
  fi

  exec "$wshowkeys" ${lib.concatMapStringsSep " " (a: "-a ${a}") anchor} \
    -m ${toString margin} -t ${toString timeout}
''
