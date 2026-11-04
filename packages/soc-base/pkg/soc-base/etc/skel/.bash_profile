# ~/.bash_profile - SOC
if [[ -z "${TMUX:-}" && "$(tty)" == "/dev/tty1" ]]; then
    exec tmux new-session -A -s soc /usr/local/bin/soc-menu
fi

trap 'clear; kill -WINCH $$ 2>/dev/null' SIGCONT

export PATH="$HOME/.local/bin:$PATH"
