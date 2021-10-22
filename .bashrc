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

__load_dotfiles() {
    dotfiles=("$HOME/.bash_aliases"
        "/usr/share/bash-completion/bash_completion"
        "/etc/bash_completion")

    for f in "${dotfiles[@]}"
    do
        [[ -r $f ]] && . "$f"
    done
}

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
    (( "$(git status --porcelain | sed -n '/??/p' | wc -l)" > 0))
    return $?
}

__git_check_staged_changes() {
    (( "$(git status --porcelain | sed -n '/A/p' | wc -l)" > 0))
    return $?
}

__git_prompt() {
    if [[ -d .git ]]
    then
        result="git"

        if __git_check_untracked_changes
        then
            result+="〘❌untracked〙"
        fi
        if __git_check_staged_changes
        then
            result+="〘✅staged〙"
        fi
    else
        result="〘🔥no .git folder〙"
    fi

    echo "$result"
}

__prompt_setup() {
    case $TERM in
        xterm-color|*-256color)
            declare -i color_prompt="$TRUE"
        ;;
    esac
    
    if [[ $color_prompt -eq "$TRUE" ]]
    then
        PS1='🌿 \[\e[1;36m\]\u@\h\[\e[0m\] ➡️  \[\e[1;34m\]\w\[\e[0m\] ➡️  \[\e[1;31m$(__git_prompt)\e[0m\]🌿\n\$ '
    else
        PS1='\u@\h:\w\:$(__git_prompt)\n\$ '
    fi
}

__miscellaneous_setup() {
    shopt -s checkwinsize
}

__load_dotfiles
__history_setup
__glob_setup
__prompt_setup
__miscellaneous_setup
