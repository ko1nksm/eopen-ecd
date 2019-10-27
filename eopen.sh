#!/bin/sh

set -eu

VERSION=0.5.1
: "${EOPEN_EDITOR:=notepad.exe}"

abort() {
  printf 'eopen: %s\n' "$*" >&2
  exit 1
}

pwsh() {
  powershell.exe -NoProfile -ExecutionPolicy Unrestricted "$@" &
}

shell() {
  explorer.exe "$@" ||: &
}

is_windrive() {
  case $1 in
    [a-zA-Z]:) return 0
  esac
  return 1
}

is_winpath() {
  case $1 in
    [a-zA-Z]:[\\/]*) return 0
  esac
  return 1
}

is_wslpath() {
  case $1 in
    [\\/][\\/]wsl\$[\\/]*) return 0
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

[ $# -eq 0 ] && set -- .
set -- "$1"
origpath="$1"

if [ -e "$1" ]; then
  path=$(readlink -f "$1")
  set -- "$path"
else
  is_windrive "$1" && set -- "$1\\"
  if is_winpath "$1" || is_wslpath "$1"; then
    path=$(wslpath -au "$1") 2>/dev/null && set -- "$path"
  fi
fi

open_editor() {
  if [ -e "$1" ] && [ ! -w "$1" ]; then
    echo 'Warning, do not have write permission' >&2
  fi
  path=$(wslpath -aw "$1")
  "$EOPEN_EDITOR" "$path" > /dev/null &
}

open_explorer() {
  path=$(wslpath -aw "$1")
  cd "$(dirname "$0")"
  pwsh ./eopen.ps1 "file://$path"
}

open_shell() {
  if is_winpath "$1" || is_protocol "$1"; then
    path=$1
  else
    [ -e "$1" ] || abort "'$origpath': No such file or directory"
    path=$(wslpath -aw "$1")
  fi
  shell "$path"
}

open() {
  if [ "$EDITOR" ]; then
    open_editor "$@"
  elif [ "$NEW" ]; then
    open_shell "$@"
  elif [ -d "$1" ]; then
    open_explorer "$@"
  else
    open_shell "$@"
  fi
}

if [ "$SUDO" ]; then
  [ -f "$1" ] || abort "'$origpath' is not a file"
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
  printf "Copy '%s' to '%s'\n" "$orgfile" "$tmpfile"
  set -- "$tmpfile"

  open "$@"

  printf 'Waiting for the file changes... To stop, press CTRL-C'
  while true; do
    sleep 1 ||:
    #shellcheck disable=SC2039
    if [ "$tmpfile" -nt "$orgfile" ]; then
      printf '\nThe file changes detected\n'
      sudo cp "$tmpfile" "$orgfile"
      printf '%s' "Wrote '$orgfile'"
    fi
  done
else
  open "$@"
fi
