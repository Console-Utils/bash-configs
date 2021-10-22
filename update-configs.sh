#!/usr/bin/env bash

declare -i SUCCESS=0
declare -i WRONG_INPUT=1

declare bold='\e[1m'
declare reset='\e[0m'

create_backup() {
  input="$1"
  directory="$2"

  suffix="old"

  old_name="$directory/$input"
  new_name="$directory/$input.$suffix"

  [[ ! -f $old_name ]] && {
    echo -e "❌ No $bold'$input'$reset file found in the $bold'$directory'$reset directory." >&2
    return "$WRONG_INPUT"
  }
  
  [[ -f $new_name ]] &&
    echo -e "⚠️ $bold'$(basename "$new_name")'$reset backup file already exists in the $bold'$directory'$reset directory and will be overridden." >&2

  cp -fT "$old_name" "$new_name"
}

dotfiles=(".bashrc"
  ".bash_aliases"
  ".bash_wrappers")

for f in "${dotfiles[@]}"
do
  create_backup "$f" "$HOME" || exit
done

repo_url="https://github.com/Console-Utils/bash-configs.git"
tmp_folder_name="/tmp/$(date +'%m/%d/%Y')"

echo "⌛Cloning started..."
git clone "$repo_url" "$tmp_folder_name" || exit
for f in "$tmp_folder_name/."bash*
do
  name="$(basename "$f")"
  cp -f "$f" "$HOME/$name"
  echo -e "✅$bold'$name'$reset file updated according to $bold'$repo_url'$reset repo."
done

rm -rf "$tmp_folder_name"
exit $SUCCESS
