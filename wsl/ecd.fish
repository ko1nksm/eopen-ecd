function ecd
  set ewd (cd "$EOPEN_ROOT"; and ./bin/ebridge.exe pwd)
  or return 1

  if string match -r "^([A-Za-z]:.*|\\\\\\\\.*)" "$ewd" >/dev/null
    set ewd (wslpath -u "$ewd" 2>/dev/null)
    if [ $status -eq 0 ]
      cd "$ewd"
      printf '%s\n' "$ewd"
      return 0
    end
  end

  printf "Unable to move to '%s'\n" "$ewd"
  return 1
end
