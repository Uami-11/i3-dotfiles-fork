#!/bin/sh
xrandr --output HDMI1 --auto --rotate left --pos 0x0 --output DP1 --off --output DP2 --off
xrandr --output eDP1 --auto --primary --right-of HDMI1 --rotate normal
