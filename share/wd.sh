#shellcheck shell=sh

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  exit 1
}

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd
) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(to_linpath "$ewd") 2>/dev/null; then
    printf '%s\n' "$dest"
    exit 0
  fi
esac

abort "Unsupported path '$ewd'"
