#!/bin/bash

inotifywait -e close_write,moved_to -m 'src' |
while read -r directory events filename; do
  if [[ "$filename" =~ .elm$ ]]; then
    echo `tput setaf 0``tput setab 5`**** Building ****`tput sgr0`
    "time" -f "Took %E" ./build.sh
  fi
done

