#!/bin/sh

set -eu

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  echo false
  exit 1
}

escape() {
  while true; do
    case ${2:-} in
      *\'*) set -- "$1" "${2#*\'}" "${3:-}${2%%\'*}'\"'\"'" ;;
      *) eval "$1=\${3:-}\${2:-}"; break ;;
    esac
  done
}

wpath() {
  if [ "$1" ] && dest=$(to_linpath "$1" 2>/dev/null); then
    printf '%s' "$dest"
    return 0
  fi

  abort "Unable to move to '$1'"
}

whome() {
  whome=$(
    cd "$EOPEN_ROOT" || exit 1
    bin/ebridge.exe env USERPROFILE
  ) || abort

  wpath "$whome"
}

ewd() {
  ewd=$(
    cd "$EOPEN_ROOT" || exit 1
    bin/ebridge.exe pwd
  ) || abort

  wpath "$ewd"
}

system=$1 sh=$2 cmd=$3 stop='' skip=''
shift 3

# shellcheck source=/dev/null
. "$EOPEN_ROOT/$system/path.sh"

for param; do
  case ${stop:+-}$param in
    -* | +*) set -- "$@" "$param" ;;
    *)
      case $param in
        [A-Za-z]:* | [\\/][\\/]*) # Windows Path
          wpath=$(wpath "$param") || abort
          param=$wpath
          ;;
        "~~" | "~~"[\\/]*) # Windows home
          whome=$(whome) || abort
          param=$whome${param#~~}
          ;;
        : | :[\\/]*) # Exploler Location
          ewd=$(ewd) || abort
          [ "${param#:}" ] || skip=1
          param=$ewd${param#:}
          ;;
      esac
      set -- "$@" "$param"
      stop=1
  esac
  shift
done

for param; do
  escape param "$param"
  set -- "$@" "'$param'"
  shift
done

set -- "$cmd" "$@"
printf "%s " "$@"

[ "$skip" ] && exit
eopen=$EOPEN_ROOT/$system/eopen.sh
escape eopen "$eopen"
if [ "$sh" = "fish" ]; then
  printf "; and sh '%s' -g ." "$eopen"
else
  printf "&& sh '%s' -g ." "$eopen"
fi
