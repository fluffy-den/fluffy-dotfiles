#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$PATH:/home/fluffy/.local/bin"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

export ANDROID_SDK_ROOT="/opt/android-sdk"

# Qt applications
export QT_QPA_PLATFORMTHEME=qt6ct

# SSH agent setup
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
  echo succeeded
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" >/dev/null
  /usr/bin/ssh-add
}

# Source SSH settings, if applicable

if [ -f "$SSH_ENV" ]; then
  . "$SSH_ENV" >/dev/null
  #ps $SSH_AGENT_PID doesn't work under Cygwin
  ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ >/dev/null || {
    start_agent
  }
else
  start_agent
fi

# Start X session automatically on tty1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
