#!/bin/bash

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
number_of_monitors=$(xrandr | grep " connected " | wc -l)

if [ "$lid_state" = "open" ]; then
    if [ "$number_of_monitors" -eq 2 ]; then
        bash ~/.screenlayout/golden.sh
    else
        xrandr --output eDP1 --primary --auto --pos 0x0 --rotate normal --output HDMI1 --off --output DP1 --off --output DP2 --off
    fi
elif [ "$lid_state" = "closed" ] && [ "$number_of_monitors" -eq 2 ]; then
    xrandr --output eDP1 --off --output HDMI1 --primary --auto --rotate left --output DP1 --off --output DP2 --off
else
    exit 1
fi
