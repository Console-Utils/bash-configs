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
    echo -e "❌ No $BOLD_FBLACK'$input'$RESET file found in the $BOLD_FBLACK'$directory'$RESET directory." >&2
    return "$WRONG_INPUT"
  }
  
  [[ -f $new_name ]] &&
    echo -e "⚠️ $BOLD_FBLACK'$(basename "$new_name")'$RESET backup file already exists in the $BOLD_FBLACK'$directory'$RESET directory and will be overridden." >&2

  cp -fT "$old_name" "$new_name"
}

declare dotfiles=("$HOME/.bash_colors")

for f in "${dotfiles[@]}"
do
    [[ -r $f ]] && . "$f"
done

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
  echo -e "✅$BOLD_FBLACK'$name'$RESET file updated according to $BOLD_FBLACK'$repo_url'$RESET repo."
done

rm -rf "$tmp_folder_name"
exit $SUCCESS
