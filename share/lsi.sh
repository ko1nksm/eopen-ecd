#shellcheck shell=sh

translate=unix

usage() {
  cat<<HERE
Usage: elsi [options]

options:
    -u    Print a Unix path (default)
    -w    Print a Windows path
    -m    Print a Windows, with '/' instead of '\'
HERE
exit
}

for arg in "$@"; do
  case $arg in
    -u | --unix) translate=unix ;;
    -w | --windows) translate=windows ;;
    -m | --mixed) translate=mixed ;;
    -h | --help) usage ;;
  esac
done

abort() {
  [ $# -gt 0 ] && printf 'elsi: %s\n' "$1" >&2
  exit 1
}

lsi() (
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe lsi
)

lsi | while IFS= read -r item; do
  case $translate in
    windows) ;;
    unix) item=$(to_linpath "$item");;
    mixed)
      IFS='\'
      set -- $item
      IFS='/'
      item=$*
  esac
  printf '%s\n' "$item"
done
