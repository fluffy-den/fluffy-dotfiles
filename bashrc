# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History configuration
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

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

# ssh
eval "$(ssh-agent -s)"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Prompt format
PS1="${CYAN}${BOLD}\u${RESET} ${MAGENTA}·${RESET} ${YELLOW}\h${RESET} ${MAGENTA}·${RESET} ${CYAN}\w${RESET} ${MAGENTA}❯${RESET} "

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lha'
alias grep='grep --color=auto'
alias vim='nvim'
alias vi='nvim'
