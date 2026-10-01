{
  pkgs,
  lib,
  # mango's own package, for mmsg.
  mango,
  framerate,
  audio,
  directory,
}:
# Monitor capture needs the setcap'd gsr-kms-server from nixosModules.mango, so
# this only works in a real session, not under nested testing.
#
# The mode argument picks what gets captured. `screen` takes the focused
# window's monitor, `window` the focused window itself, and `region` asks slurp.
pkgs.writeShellScriptBin "mango-record" ''
  set -eu
  export PATH=${lib.makeBinPath [
    mango
    pkgs.gpu-screen-recorder
    pkgs.slurp
    pkgs.jq
    pkgs.coreutils
  ]}:$PATH

  mode=''${1:-screen}
  pidfile=''${XDG_RUNTIME_DIR:-/tmp}/mango-record.pid

  # A second invocation stops the recording, checked before the mode so no
  # region picker appears first. SIGINT so gsr finalizes the container. The pid
  # needs a file: comm is truncated to 15 chars, so `pkill -x
  # gpu-screen-recorder` never matches.
  if [ -e "$pidfile" ] && kill -INT "$(cat "$pidfile")" 2>/dev/null; then
    rm -f "$pidfile"
    exit 0
  fi
  rm -f "$pidfile"

  case "$mode" in
    screen)
      # gsr's `-w focused` is X11-only, but it takes a connector name, which is
      # what mango reports as the focused client's monitor. Fall back to the
      # pointer's monitor on an empty tag.
      monitor=$(mmsg get focusing-client | jq -r '.monitor // empty' || true)
      if [ -z "$monitor" ]; then
        monitor=$(mmsg get cursorpos | jq -r '.monitor // empty' || true)
      fi
      if [ -z "$monitor" ]; then
        echo "mango-record: could not determine the focused monitor" >&2
        exit 1
      fi
      set -- -w "$monitor"
      ;;
    region)
      # Esc cancels, which slurp reports as a nonzero exit. A no-op, not an error.
      region=$(slurp -f '%wx%h+%x+%y') || exit 0
      set -- -w region -region "$region"
      ;;
    *)
      echo "mango-record: unknown mode '$mode' (expected screen or region)" >&2
      exit 1
      ;;
  esac

  # Unquoted at build time so the option can use $HOME; quoted here for spaces.
  mkdir -p "${directory}"
  gpu-screen-recorder "$@" -f ${toString framerate} -k h264 \
    ${lib.concatMapStringsSep " " (a: "-a ${lib.escapeShellArg a}") audio} \
    -o "${directory}/recording-$(date +%Y%m%d-%H%M%S).mp4" &
  pid=$!
  echo "$pid" >"$pidfile"
  # Clear the pidfile on any exit; a stale one risks SIGINTing a recycled pid.
  trap 'rm -f "$pidfile"' EXIT
  wait "$pid"
''
