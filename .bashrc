#!/usr/bin/env bash

# shellcheck disable=SC2034

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
        . .bash_aliases
    fi

    if ! shopt -oq posix; then
        if [[ -f /usr/share/bash-completion/bash_completion ]]
        then
            . /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]
        then
            . /etc/bash_completion
        fi
    fi
}

function prompt_setup() {
    case "$TERM" in
        xterm-color|*-256color)
            declare -i color_prompt="$TRUE"
        ;;
    esac
    
    if [[ "$color_prompt" -eq "$TRUE" ]]
    then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='\u@\h:\w\$ '
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
