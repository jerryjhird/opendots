# interactive terminal check
[[ $- != *i* ]] && return

# env variables
export CC="gcc"
export LD="mold"
export CXXLD="mold"

# default compiler flags
export CFLAGS="-O2 -march=native -pipe"
export CXXFLAGS="-O2 -march=native -pipe"

# history
export HISTSIZE=30
export HISTCONTROL=ignoredups:erasedups

shopt -s checkwinsize # re calculate window size if changed
shopt -s cdspell # file path auto correct for cd
shopt -s extglob # extended file querying

# cache local ip for prompt
LOCAL_IP=$(ip route get 1.1.1.1 | awk -F"src " 'NR==1{split($2,a," "); print a[1]}')

# if root else
if [[ $EUID -eq 0 ]]; then
  PS1='\[\033[01;31m\][\u@\h \W]\$\[\033[00m\] '
else
  PS1='\[\e[37m\][\[\e[90m\]$?\[\e[37m\]]\[\e[0m\] \[\e[90;1m\][\[\e[0;37m\]\T\[\e[90;1m\]]\[\e[0m\] \[\e[32;1m\]\u@'"${LOCAL_IP}"'\[\e[0m\] \[\e[32;1m\](\w)\$\[\e[0m\] '
fi

# toolchain specific
alias gc='git clone'

# util aliases
alias _='sudo'
alias reload='source ~/.bashrc'
alias ls='ls --color=auto -a'
alias grep='grep --colour=auto'
alias back='cd "$OLDPWD"'
alias ..='cd ..'

#path
export PATH=$HOME/.local/bin:$PATH

# setup cargo (if exists)
if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi