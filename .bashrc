#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cpp14='clang++ -Wall -Wextra -std=c++14'
alias weather='curl wttr.in/L7J1M9'
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"
PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
#PS1='${GREEN}\u${RESET}> '
export PATH="~/.scripts:$PATH"
export PATH="~/.dotnet/tools:$PATH"
export PATH="/usr/lib/jvm/java-21-openjdk/bin:$PATH"

# Created by `pipx` on 2025-06-24 15:40:49
export PATH="$PATH:/home/keith/.local/bin"
export MANPAGER="nvim +Man!"

# Set nvim as default editor
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
eval "$(starship init bash)"
