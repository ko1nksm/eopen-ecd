#shellcheck shell=sh

unix=1 mixed=''

usage() {
  cat<<HERE
Usage: ewd [options]

options:
    -u, --unix      Print a Unix path (default)
    -w, --windows   Print a Windows path
    -m, --mixed     Print a Windows, with '/' instead of '\'
HERE
exit
}

for arg in "$@"; do
  case $arg in
    -u | --unix)    unix=1  mixed='' ;;
    -w | --windows) unix='' mixed='' ;;
    -m | --mixed)   unix='' mixed=1  ;;
    -h | --help) usage ;;
  esac
done

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  exit 1
}

[ "$mixed" ] && options=m || options=''

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd unicode "$options"
) || abort

if [ "$unix" ]; then
  case $ewd in ([A-Za-z]:* | \\\\*)
    if dest=$(to_linpath "$ewd") 2>/dev/null; then
      printf '%s\n' "$dest"
      exit 0
    fi
  esac
else
  printf '%s\n' "$ewd"
  exit 0
fi

abort "Unsupported path '$ewd'"
