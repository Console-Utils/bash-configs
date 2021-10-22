#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i WRONG_INPUT=1

create_backup() {
  input="$1"
  directory="$2"

  suffix="old"

  old_name="$directory/$input"
  new_name="$directory/$input.$suffix"

  [[ ! -f $old_name ]] && {
    echo "No '$input' file found in the '$directory' directory." >&2
    return "$WRONG_INPUT"
  }
  
  [[ -f $new_name ]] &&
    echo "'$new_name' file already exists in the '$directory' directory and will be overridden." >&2

  cp -fT "$old_name" "$new_name"
}

dotfiles=(".bashrc"
  ".bash_aliases"
  ".bash_wrappers")

for f in "${dotfiles[@]}"
do
  create_backup "$f" "$HOME"
done

repo_url="https://github.com/Console-Utils/bash-configs.git"
tmp_folder_name="/tmp/$(date +'%m/%d/%Y')"

git clone "$repo_url" "$tmp_folder_name"
for f in "$tmp_folder_name/."bash*
do
  name="$(basename "$f")"
  cp -f "$f" "$HOME/$name"
  echo "'$name' file updated according to '$repo_url' repo."
done

rm -rf "$tmp_folder_name"
exit $SUCCESS
