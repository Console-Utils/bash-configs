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
    [[ ! -d .git ]] && {
        echo "[🔥no .git folder]"
        exit
    }

    local result="git "

    local branch
    branch="$(git branch --show-current)"

    result+="("

    if [[ -z $branch ]]; then
        result+="❌ not on branch"
    else
        [[ "$(git branch -r --contains "origin/$branch")" == "" ]] && result+="⚠️ "
        result+="$branch"
    fi

    readarray -d $'\t' -t commit_difference < <(echo -e "$(git rev-list --left-right --count "origin/main...main")\t")
    
    local -i commits_behind="${commit_difference[0]}"
    local -i commits_ahead="${commit_difference[1]}"

    local commit_difference_info=

    (( commits_behind != 0 )) && commit_difference_info+="⬇️ $commits_behind"
    (( commits_ahead != 0 )) && {
        [[ -n $commit_difference_info ]] && commit_difference_info+=" "
        commit_difference_info+="⬆️ $commits_ahead"
    }

    [[ -n $commit_difference_info ]] && result+=" $commit_difference_info"
    result+=")"

    local -i untracked_count
    local -i staged_count
    untracked_count="$(__git_check_untracked_changes)"
    staged_count="$(__git_check_staged_changes)"

    local status_info=
    
    (( untracked_count > 0 )) && {
        status_info+="❌untracked:$untracked_count"
    }
    (( staged_count > 0 )) && {
        [[ -n $status_info ]] && status_info+=" "
        status_info+="✅staged:$staged_count"
    }

    [[ -n $status_info ]] && result+="[$status_info]"

    echo "$result"
}

__print_pipeline_statuses() {
    local statuses=("$@")

    [[ -z ${statuses[0]} ]] && return
    
    echo -n "[${statuses[0]}"
    for ((i=1; i < "${#statuses[@]}"; i++)); do
        echo -n "|${statuses[i]}"
    done

    echo -n "]"
}

__simplify_pwd() {
    local directory="$1"
    
    directory="$(echo "$directory" | sed "s|^$HOME/Documents/mine|\\\\\$MINE_PATH|; s|^$HOME/Documents/work|\\\\\$WORK_PATH|; s|$HOME|~|")"
    echo "$directory"
}

__prompt_setup() {
    case $TERM in
        xterm-color|*-256color)
            local -i color_prompt="$TRUE"
        ;;
    esac

    PROMPT_COMMAND='
    declare statuses=("${PIPESTATUS[@]}")

    if [[ $color_prompt -eq "$TRUE" ]]
    then
        PS1="🌿 \[$BOLD_FCYAN\]\u@\h\[$RESET\] ➡️  \[$BOLD_FBLUE\]$(__simplify_pwd $PWD)\[$RESET\] ➡️  \[$BOLD_FMAGENTA\]$(__print_pipeline_statuses ${statuses[@]})\[$RESET\] ➡️  \[$BOLD_FRED\]$(__git_prompt)\[$RESET\]🌿\n\$ "
    else
        PS1="\u@\h:\w\:$(__git_prompt)\n\$ "
    fi'
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
