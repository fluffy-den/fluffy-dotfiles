# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History configuration
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist

# Default compilers
export CC=clang
export CXX=clang++
export LD=lld
export AR=llvm-ar
export NM=llvm-nm
export RANLIB=llvm-ranlib

# Default applications
export TERMINAL=kitty
export EDITOR=nvim
export VISUAL=nvim

# Dark theme for GTK applications
export GTK_THEME=Adwaita:dark

# Dotnet configuration
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:${DOTNET_ROOT}:${DOTNET_ROOT}/tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Custom colored prompt
# Colors
RESET='\[\033[0m\]'
CYAN='\[\033[0;36m\]'
MAGENTA='\[\033[0;35m\]'
YELLOW='\[\033[0;33m\]'
BOLD='\[\033[1m\]'

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# Go
export PATH="$PATH:$HOME/go/bin"

# Prompt format
PS1="${CYAN}${BOLD}\u${RESET} ${MAGENTA}·${RESET} ${YELLOW}\h${RESET} ${MAGENTA}·${RESET} ${CYAN}\w${RESET} ${MAGENTA}❯${RESET} "

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lha'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias vim='nvim'
alias vi='nvim'
alias ..='cd ..'
alias ...='cd ../..'

# Yazi - cd on quit wrapper (use 'y' to launch; shell follows into last directory)
function y() {
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || exit
  fi
  rm -f -- "$tmp"
}
alias fm='y'

# NVM (Node Version Manager) initialization
export NVM_DIR="$HOME/.nvm"
export PATH=$HOME/.npm-global/bin:$PATH
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
