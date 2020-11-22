#!/usr/bin/env bash

output=''

for project in `find ~/Code -type d -d 1`; do
  cd "$project"
  remote=`git config --get remote.origin.url`
  if [ -d "$project/.git" ] && [ ! -z "$remote" ]; then
    if [ -z "$output" ]; then
      output="${PWD##*/}|$remote"
    else
      output="$output"$'\n'"${PWD##*/}|$remote"
    fi
  fi
done

echo "$output" > ~/Code/git-remote-dump.txt

echo "A file with all git remotes is created at ~/Code/git-remote-dump.txt"
