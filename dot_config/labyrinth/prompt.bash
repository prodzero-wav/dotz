# LABYRINTH bash prompt: user ~/path ▸
PS1='\[\e[38;2;111;159;139m\]\u\[\e[0m\] \[\e[38;2;212;203;168m\]\w\[\e[0m\] ▸ '

# fastfetch on every new terminal (only inside the sway session, not on the TTY)
[[ $- == *i* && -n "$WAYLAND_DISPLAY" ]] && fastfetch
