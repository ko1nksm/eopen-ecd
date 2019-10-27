#!/bin/sh

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$*" >&2
  exit 1
}

pwsh() {
  powershell.exe -NoProfile -ExecutionPolicy Unrestricted "$@"
}

ewd() {
  cd "$(dirname "$0")" || exit 1
  pwsh ./ewd.ps1
}

ewd=$(ewd) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd") 2>/dev/null; then
    # shellcheck disable=SC2028
    printf '%s\n' "$dest"
    exit
  fi
esac

abort "Unsupported path '$ewd'"
exit 1
