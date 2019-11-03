#!/bin/sh

set -eu

ebridge="${0%/*}/../bin/ebridge.exe"

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$*" >&2
  exit 1
}

ebridge() (
  cd "${ebridge%/*}" || exit 1
  "./${ebridge##*/}" "$@"
)

ewd=$(ebridge pwd) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd") 2>/dev/null; then
    # shellcheck disable=SC2028
    printf '%s\n' "$dest"
    exit
  fi
esac

abort "Unsupported path '$ewd'"
exit 1
