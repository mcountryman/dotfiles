#!/usr/bin/env sh

while swaymsg "output * bg $(find ~/Pictures/Wallpapers -type f | shuf -n 1) fill"; do 
  sleep 5m; 
done