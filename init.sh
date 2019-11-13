#!/bin/sh

set -eu

BASE=$(cd "$(dirname "$0")"; pwd)
UNAME=$(uname -s)

case $(uname -s) in
  CYGWIN* | MINGW* | MSYS*) system=cygwin ;;
  *) system=wsl ;;
esac

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
alias eopen='sh "\$EOPEN_ROOT/$system/eopen.sh"'
alias eclose='sh "\$EOPEN_ROOT/$system/eclose.sh"'
alias ewd='sh "\$EOPEN_ROOT/$system/ewd.sh"'
alias ecd='. "\$EOPEN_ROOT/$system/ecd.sh"'
if type pushd >/dev/null 2>&1; then
  alias epushd='. "\$EOPEN_ROOT/$system/epushd.sh"'
  alias epopd='. "\$EOPEN_ROOT/$system/epopd.sh"'
fi
alias elsi='sh "\$EOPEN_ROOT/$system/elsi.sh"'
HERE
;;

(tcsh) cat<<HERE
setenv EOPEN_ROOT '$BASE';
alias eopen 'sh "\$EOPEN_ROOT/$system/eopen.sh"';
alias eclose 'sh "\$EOPEN_ROOT/$system/eclose.sh"';
alias ewd 'sh "\$EOPEN_ROOT/$system/ewd.sh"';
alias ecd 'source "\$EOPEN_ROOT/$system/ecd.tcsh"';
alias epushd 'source "\$EOPEN_ROOT/$system/epushd.tcsh"';
alias epopd 'source "\$EOPEN_ROOT/$system/epopd.tcsh"';
alias elsi 'sh "\$EOPEN_ROOT/$system/elsi.sh"';
HERE
;;

(fish) cat<<HERE
set EOPEN_ROOT '$BASE';
alias eopen='sh "\$EOPEN_ROOT/$system/eopen.sh"';
alias eclose='sh "\$EOPEN_ROOT/$system/eclose.sh"';
alias ewd='sh "\$EOPEN_ROOT/$system/ewd.sh"';
alias ecd='source "\$EOPEN_ROOT/$system/ecd.fish"';
alias epushd='source "\$EOPEN_ROOT/$system/epushd.fish"';
alias epopd='source "\$EOPEN_ROOT/$system/epopd.fish"';
alias elsi='sh "\$EOPEN_ROOT/$system/elsi.sh"';
HERE
;;

(*) echo "Invalid shell type" >&2

esac
