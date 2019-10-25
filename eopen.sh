#!/bin/sh

set -eu

VERSION=0.2.1

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
  case $1 in (*:*)
    case ${1%%:*} in (*[!0-9a-zA-Z]*)
      return 1
    esac
    return 0
  esac
  return 1
}

usage() {
  cat <<'HERE'
Usage: eopen [options] [file | directory | uri]

options:
  -e, --editor      Open the file in text editor ($EOPEN_EDITOR)
  -n, --new         Open the specified directory in new instance of explorer
      --sudo        Use sudo to write the unowned file
  -v, --version     Display the version
  -h, --help        You're looking at it

note:
  The file or the directory allows linux and windows path.
  (e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts)

  The uri must start with protocol schema. (e.g http:, https:)
HERE
exit
}

EDITOR='' NEW='' SUDO=''

for arg; do
  case $arg in
    -e | --editor ) EDITOR=1 ;;
    -n | --new    ) NEW=1 ;;
         --sudo   ) SUDO=1 ;;
    -v | --version) echo "$VERSION"; exit ;;
    -h | --help   ) usage ;;
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

if [ "$SUDO" ]; then
  [ -f "$1" ] || abort "'$1' is not a file"
  tmpdir='' tmpfile=''

  cleanup() {
    if [ -f "$tmpfile" ]; then
      printf '\n%s\n' "Delete tempfile '$tmpfile'"
      rm "$tmpfile"
      [ -d "$tmpdir" ] && rmdir "$tmpdir"
    fi
    exit
  }
  trap cleanup INT TERM

  tmpdir=$(mktemp -d)
  orgfile="$1" tmpfile=$tmpdir/${1##*/}
  cp --preserve=timestamps "$orgfile" "$tmpfile"
  printf "Copy '$orgfile' to '$tmpfile'\n"
  shift
  set -- "$tmpfile" "$@"

  open "$@"
  printf 'Waiting for the file changes... To stop, press CTRL-C'
  while true; do
    sleep 1 ||:
    if [ "$tmpfile" -nt "$orgfile" ]; then
      printf '\nThe file changes detected\n'
      sudo cp "$tmpfile" "$orgfile"
      printf '%s' "Wrote '$orgfile'"
    fi
  done
else
  open "$@"
fi
