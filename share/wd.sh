#shellcheck shell=sh

translate=unix

usage() {
  cat<<HERE
Usage: ewd [options]

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
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  exit 1
}

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd
) || abort

case $translate in
  unix)
    case $ewd in ([A-Za-z]:* | \\\\*)
      if dest=$(to_linpath "$ewd") 2>/dev/null; then
        printf '%s\n' "$dest"
        exit 0
      fi
    esac
    ;;
  mixed)
    IFS='\'
    set -- $ewd
    IFS='/'
    ewd=$*
    printf '%s\n' "$ewd"
    exit 0
    ;;
  windows)
    printf '%s\n' "$ewd"
    exit 0
    ;;
esac

abort "Unsupported path '$ewd'"
