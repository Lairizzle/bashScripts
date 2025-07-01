#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cpp14='clang++ -Wall -Wextra -std=c++14'
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"
PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
#PS1='${GREEN}\u${RESET}> '
export PATH="~/.scripts:$PATH"
