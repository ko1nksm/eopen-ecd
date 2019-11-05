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

escape() {
  while true; do
    case ${2:-} in
      *\'*) set -- "$1" "${2#*\'}" "${3:-}${2%%\'*}\"'\"" ;;
      *) eval "$1=\${3:-}\${2:-}"; break ;;
    esac
  done
}

ewd() {
  ewd=$(
    cd "$EOPEN_ROOT" || exit 1
    bin/ebridge.exe pwd
  ) || abort

  case $ewd in ([A-Za-z]:* | \\\\*)
    if dest=$(wslpath -u "$ewd" 2>/dev/null); then
      printf '%s' "$dest"
      return 0
    fi
  esac

  abort "Unable to move to '$ewd'"
}

cmd=$1 stop='' at=''
shift

for param; do
  case ${stop:+-}$param in
    -* | +*) set -- "$@" "$param" ;;
    *)
      case $param in
        "~~" | "~~/"*) # Windows home
          whome=''
          # param="$whome${param#~~}"
          ;;
        [A-Za-z]:* | \\\\*) # Windowd Path
          ewd=$(ewd) || abort
          param=$ewd
          ;;
        "@" | "@/"*) # Current Exploler Location
          ewd=$(ewd) || abort
          param="$ewd${param#@}"
          [ "${param#@}" ] || at=1
          ;;
      esac
      set -- "$@" "$param"
      stop=1
  esac
  shift
done

for param; do
  escape param "$param"
  set -- "$@" "$param"
  shift
done

set -- "$cmd" "$@"
printf "'%s' " "$@"

if [ ! "$at" ]; then
  escape eopen "${0%/*}/eopen.sh"
  printf "&& sh '%s' -g ." "$eopen"
fi
