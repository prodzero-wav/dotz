# LABYRINTH: make Qt apps follow the GTK theme
set -gx QT_QPA_PLATFORMTHEME gtk3
set -gx QT_QPA_PLATFORM "wayland;xcb"

# fastfetch on every new terminal (only inside the sway session, not on the TTY)
if status is-interactive; and set -q WAYLAND_DISPLAY
    fastfetch
end
