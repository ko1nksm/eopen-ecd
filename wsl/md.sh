#!/bin/sh

md() {
  while true; do
    case ${2:-} in
      *\'*) set -- "$1" "${2#*\'}" "${3:-}${2%%\'*}'\"'\"'" ;;
      *) set -- "$1" "${3:-}${2:-}"; break ;;
    esac
  done
  printf "%s '%s'" "$1" "$2"
}

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  echo false
  exit 1
}

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd
) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if ewd=$(wslpath -u "$ewd" 2>/dev/null); then
    md "$1" "$ewd"
    return 0
  fi
esac

abort "Unable to move to '$ewd'"
