#!/usr/bin/env bash

if [ ! -f "$1" ]; then
  echo "File $1 not found!"
  exit
fi

cd ~/Code

while read remote; do
  IFS='|' read -ra project <<< "$remote"
  echo "git clone \"${project[1]}\" \"~/Code/${project[0]}\""
  git clone "${project[1]}" ~/Code/"${project[0]}"
done < "$1"
