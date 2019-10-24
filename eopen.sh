#!/bin/sh

set -eu

[ $# -eq 0 ] && set -- .

abort() {
  echo "eopen: $*" >&2
  exit 1
}

pwsh() {
  powershell.exe -ExecutionPolicy Unrestricted "$@"
}

is_winpath() {
  case $1 in
    [a-zA-Z]:[\\/]*) return 0
  esac
  return 1
}

is_protocol() {
  case ${1%%://*} in
    *[!0-9a-zA-Z]*) return 1
  esac
  return 0
}

usage() {
  cat <<'HERE'
Usage: eopen [-e | -n] [file | directory | protocol]

examples
  eopen                     # Open the current directory in explorer.
  eopen /etc/               # Open the specified directory in explorer.
  eopen -n /etc/            # Open the specified directory in new instance of explorer.
  eopen ~/image.jpg         # Open the file in associated application.
  eopen -e /etc/hosts       # Open the file in text editor ($EOPEN_EDITOR).
  eopen http://google.com   # Open the url in default browser.

  The path of file or directory allows linux and windows path.
  (e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts)
HERE
exit
}

EDITOR='' NEW=''

for arg; do
  case $arg in
    -e | --editor) EDITOR=1 ;;
    -n | --new) NEW=1 ;;
    -h | --help) usage ;;
    -?*) abort "unrecognized option '$arg'" ;;
    *) set -- "$@" "$arg"
  esac
  shift
done

if [ "$EDITOR" ]; then
  if [ ! "${EOPEN_EDITOR:-}" ]; then
    # shellcheck disable=SC2016
    abort 'Environment variable $EOPEN_EDITOR is not set'
  fi

  if [ $# -gt 0 ]; then
    tmp=$(wslpath -aw "$1")
    set -- "$tmp"
  fi
  "$EOPEN_EDITOR" "$@"
else
  if is_winpath "$1"; then
    set -- "file://$1"
  elif ! is_protocol "$1"; then
    [ -e "$1" ] || abort "'$1': No such file or directory"
    tmp=$(wslpath -aw "$1")
    set -- "$tmp"
  fi

  [ "$NEW" ] && set -- -New "$@"

  cd "$(dirname "$0")"
  pwsh ./eopen.ps1 "$@"
fi
