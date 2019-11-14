#shellcheck shell=sh

unix=1 mixed='' delimiter='\n'

usage() {
  cat<<HERE
Usage: elsi [options]

options:
    -u, --unix      Print a Unix path (default)
    -w, --windows   Print a Windows path
    -m, --mixed     Print a Windows, with '/' instead of '\'
    -0, --null      items are separated by a null, not whitespace
HERE
exit
}

for arg in "$@"; do
  case $arg in
    -u | --unix)    unix=1  mixed='' ;;
    -w | --windows) unix='' mixed='' ;;
    -m | --mixed)   unix='' mixed=1  ;;
    -0 | --null) delimiter='\0' ;;
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

CR=$(printf '\r')

[ "$mixed" ] && options=m || options=''

lsi "$options" | while IFS= read -r item; do
  item=${item%"$CR"}
  [ "$unix" ] && item=$(to_linpath "$item")
  printf "%s$delimiter" "$item"
done
