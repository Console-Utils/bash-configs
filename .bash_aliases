#!/usr/bin/env bash

alias e="echo"
alias pf="printf"

alias i="if test"
alias w="while test"
alias f="for"

if command -v git &> /dev/null
then
  alias gi="git init"
  alias gc="git clone"
  alias gu="rm -rf .git"
fi

alias r=". ~/.bashrc"
