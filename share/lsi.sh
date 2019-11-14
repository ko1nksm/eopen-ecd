#shellcheck shell=sh

unix=1 mixed=''

usage() {
  cat<<HERE
Usage: elsi [options]

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
  [ $# -gt 0 ] && printf 'elsi: %s\n' "$1" >&2
  exit 1
}

lsi() (
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe lsi "$@"
)

[ "$mixed" ] && options=m || options=''

lsi "$options" | while IFS= read -r item; do
  [ "$unix" ] && item=$(to_linpath "$item")
  printf '%s\n' "$item"
done
