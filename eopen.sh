#!/bin/sh

set -eu

VERSION=0.1.0

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
Usage: eopen [options] [file | directory | uri]

options:
  -e, --editor      Open the file in text editor ($EOPEN_EDITOR)
  -n, --new         Open the specified directory in new instance of explorer
  -v, --version     Display the version
  -h, --help        You're looking at it

note:
  The file or the directory allows linux and windows path.
  (e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts)

  The uri must start with protocol schema. (e.g http:, https:)
HERE
exit
}

EDITOR='' NEW=''

for arg; do
  case $arg in
    -e | --editor) EDITOR=1 ;;
    -n | --new) NEW=1 ;;
    -h | --help) usage ;;
    -v | --version) echo "$VERSION"; exit ;;
    -?*) abort "unrecognized option '$arg'" ;;
    *) set -- "$@" "$arg"
  esac
  shift
done

open_editor() {
  if [ ! "${EOPEN_EDITOR:-}" ]; then
    # shellcheck disable=SC2016
    abort 'Environment variable $EOPEN_EDITOR is not set'
  fi

  if [ $# -gt 0 ]; then
    winpath=$(wslpath -aw "$1")
    shift
    set -- "$winpath" "$@"
  fi
  "$EOPEN_EDITOR" "$@"
}

open_explorer() {
  if is_winpath "$1"; then
    set -- "file://$1"
  elif ! is_protocol "$1"; then
    [ -e "$1" ] || abort "'$1': No such file or directory"
    winpath=$(wslpath -aw "$1")
    shift
    set -- "$winpath" "$@"
  fi

  [ "$NEW" ] && set -- -New "$@"

  cd "$(dirname "$0")"
  pwsh ./eopen.ps1 "$@"
}

open() {
  if [ "$EDITOR" ]; then
    open_editor "$@"
  else
    open_explorer "$@"
  fi
}

open "$@"
