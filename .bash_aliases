#!/usr/bin/env bash

# shellcheck disable=SC1090

alias e="echo" # [E]cho
alias pf="printf" # [P]rint[F]

alias i="if test" # [I]f
alias w="while test" # [W]hile
alias f="for" # [F]or

if command -v git &> /dev/null
then
  alias gin="git init" # [G]it [IN]it
  alias gcl="git clone" # [G]it [CL]lone
  alias gun="rm -rf .git" # [G]it [UN]init

  if [[ -f ~/.bash_wrappers ]]
  then
    . ~/.bash_wrappers
    alias gre="git_repo_recreate" # [G]it [RE]create
  fi

  alias gsw="git switch" # [G]it [SW]itch
  alias gfe="git fetch" # [G]it [FE]tch
  alias gsy="git pull && git push" # [G]it [SY]nc
fi

alias r=". ~/.bashrc" # [R]eload
