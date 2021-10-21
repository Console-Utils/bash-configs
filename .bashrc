#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC1090

declare -i TRUE=0
declare -i FALSE=1

function setup_history() {
    shopt -s histappend

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000
}

function glob_setup() {
    shopt -s globstar
    shopt -s failglob
}

function alias_setup() {
    if [[ -f ~/.bash_aliases ]]
    then
        . ~/.bash_aliases
    fi

    if ! shopt -oq posix
    then
        if [[ -f /usr/share/bash-completion/bash_completion ]]
        then
            . /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]
        then
            . /etc/bash_completion
        fi
    fi
}

function git_check_untracked_changes() {
    (( "$(git status --porcelain | sed -n '/??/p' | wc -l)" > 0))
    return $?
}

function git_check_staged_changes() {
    (( "$(git status --porcelain | sed -n '/A/p' | wc -l)" > 0))
    return $?
}

function git_prompt() {
    if [[ -d .git ]]
    then
        result="git"

        if git_check_untracked_changes
        then
            result+="-untracked"
        fi
        if git_check_staged_changes
        then
            result+="-staged"
        fi
    else
        result=
    fi

    echo "$result"
}

function prompt_setup() {
    case "$TERM" in
        xterm-color|*-256color)
            declare -i color_prompt="$TRUE"
        ;;
    esac
    
    if [[ "$color_prompt" -eq "$TRUE" ]]
    then
        PS1='\[\e[1;36m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]:\[\e[1;31m$(git_prompt)\e[0m\]\n\$ '
    else
        PS1='\u@\h:\w\:$(git_prompt)\n\$ '
    fi
}

function miscellaneous_setup() {
    shopt -s checkwinsize
}

case $- in
    *i*)
    ;;
    *)
        return
    ;;
esac

setup_history
glob_setup
alias_setup
prompt_setup
miscellaneous_setup
