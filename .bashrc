#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC1090

case $- in
    *i*)
    ;;
    *)
        return
    ;;
esac

declare -i TRUE=0
declare -i FALSE=1

export MINE_PATH="$HOME/Documents/mine/"
export WORK_PATH="$HOME/Documents/work/"

export GLOBIGNORE=".bashrc*:.bash_aliases*:.bash_wrappers*"

__history_setup() {
    shopt -s histappend

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000
}

__glob_setup() {
    shopt -s globstar
    shopt -s extglob
    shopt -s dotglob
    shopt -s failglob
}

__git_check_untracked_changes() {
    local -i count
    count="$(git status --porcelain | sed -n '/??/p' | wc -l)"
    echo "$count"
}

__git_check_staged_changes() {
    local -i count
    count="$(git status --porcelain | sed -n '/A/p' | wc -l)"
    echo "$count"
}

__git_prompt() {
    if [[ -d .git ]]
    then
        local result="git"

        local -i untracked_count
        local -i staged_count

        untracked_count="$(__git_check_untracked_changes)"
        staged_count="$(__git_check_staged_changes)"
        
        (( untracked_count > 0 )) && result+="〘❌untracked:$untracked_count〙"
        (( staged_count > 0 )) && result+="〘✅staged:$staged_count〙"
    else
        result="〘🔥no .git folder〙"
    fi

    echo "$result"
}

__prompt_setup() {
    case $TERM in
        xterm-color|*-256color)
            local -i color_prompt="$TRUE"
        ;;
    esac
    
    if [[ $color_prompt -eq "$TRUE" ]]
    then
        PS1='🌿 \[$BOLD_FCYAN\]\u@\h\[$RESET\] ➡️  \[$BOLD_FBLUE\]\w\[$RESET\] ➡️  \[$BOLD_FRED\]$(__git_prompt)\[$RESET\]🌿\n\$ '
    else
        PS1='\u@\h:\w\:$(__git_prompt)\n\$ '
    fi
}

__miscellaneous_setup() {
    shopt -s checkwinsize
}

declare dotfiles=("$HOME/.bash_aliases"
    "$HOME/.bash_colors"
    "/usr/share/bash-completion/bash_completion"
    "/etc/bash_completion")

for f in "${dotfiles[@]}"
do
    [[ -r $f ]] && . "$f"
done

__history_setup
__glob_setup
__prompt_setup
__miscellaneous_setup
