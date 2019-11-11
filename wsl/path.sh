#shellcheck shell=sh

to_linpath_workaround() {
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

to_linpath() {
  wslpath -u "$1" | sed "$(to_linpath_workaround)"
}

to_winpath() {
  wslpath -aw "$1"
}
