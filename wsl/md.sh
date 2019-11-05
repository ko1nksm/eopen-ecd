#!/bin/sh

set -eu

list() {
  set --
  i=1
  while [ $i -lt 32 ]; do
    set -- "$@" 128 $((i + 128)) "$i"
    i=$((i+1))
  done
  set -- "$@" 128 162 34  128 170 42  128 186 58  128 188 60
  set -- "$@" 128 190 62  128 191 63  129 156 92  129 188 124
  printf 's!\xEF\x%X\x%X!\x%X!g\n' "$@"
}

wslpath() {
  command wslpath "$@" | sed "$(list)"
}

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  echo false
  exit 1
}

md() {
  while true; do
    case ${2:-} in
      *\'*) set -- "$1" "${2#*\'}" "${3:-}${2%%\'*}'\"'\"'" ;;
      *) set -- "$1" "${3:-}${2:-}"; break ;;
    esac
  done
  printf "%s '%s'" "$1" "$2"
}

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd
) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd" 2>/dev/null); then
    md "$1" "$dest"
    return 0
  fi
esac

abort "Unable to move to '$ewd'"
