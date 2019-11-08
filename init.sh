#!/bin/sh

set -eu

BASE=$(cd "$(dirname "$0")"; pwd)

cd "$BASE"
if [ ! -x "bin/ebridge.exe" ]; then
  echo "[eopen-ecd] ebridge.exe not found or is not executable." >&2
  echo "Place ebridge.exe and enter the following command." >&2
  echo " chmod +x '$BASE/bin/ebridge.exe'" >&2
  exit 1
fi

escape() {
  while true; do
    case ${2:-} in
      *\'*) set -- "$1" "${2#*\'}" "${3:-}${2%%\'*}'\"'\"'" ;;
      *) eval "$1=\${3:-}\${2:-}"; break ;;
    esac
  done
}

escape BASE "$BASE"

case ${1:-sh} in

(sh) cat<<HERE
export EOPEN_ROOT='$BASE'
alias eopen='sh "\$EOPEN_ROOT/wsl/eopen.sh"'
alias eclose='sh "\$EOPEN_ROOT/wsl/eclose.sh"'
alias ewd='sh "\$EOPEN_ROOT/wsl/ewd.sh"'
alias ecd='. "\$EOPEN_ROOT/wsl/ecd.sh"'
if type pushd >/dev/null 2>&1; then
  alias epushd='. "\$EOPEN_ROOT/wsl/epushd.sh"'
  alias epopd='. "\$EOPEN_ROOT/wsl/epopd.sh"'
fi
HERE
;;

(tcsh) cat<<HERE
setenv EOPEN_ROOT '$BASE';
alias eopen 'sh "\$EOPEN_ROOT/wsl/eopen.sh"';
alias eclose 'sh "\$EOPEN_ROOT/wsl/eclose.sh"';
alias ewd 'sh "\$EOPEN_ROOT/wsl/ewd.sh"';
alias ecd 'source "\$EOPEN_ROOT/wsl/ecd.tcsh"';
alias epushd 'source "\$EOPEN_ROOT/wsl/epushd.tcsh"';
alias epopd 'source "\$EOPEN_ROOT/wsl/epopd.tcsh"';
HERE
;;

(fish) cat<<HERE
set EOPEN_ROOT '$BASE';
alias eopen='sh "\$EOPEN_ROOT/wsl/eopen.sh"';
alias eclose='sh "\$EOPEN_ROOT/wsl/eclose.sh"';
alias ewd='sh "\$EOPEN_ROOT/wsl/ewd.sh"';
alias ecd='source "\$EOPEN_ROOT/wsl/ecd.fish"';
alias epushd='source "\$EOPEN_ROOT/wsl/epushd.fish"';
alias epopd='source "\$EOPEN_ROOT/wsl/epopd.fish"';
HERE
;;

(*) echo "Invalid shell type" >&2

esac
