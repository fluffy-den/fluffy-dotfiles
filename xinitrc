#!/bin/bash

# Set AZERTY layout
setxkbmap fr

# Restore wallpaper
feh --bg-scale ~/pictures/wallpeper.jpeg &

# Start compositor for shadows &
transparency
picom --config ~/.config/i3/picom.conf &

# Autorandr
autorandr --change --default default

# Start i3
exec i3
