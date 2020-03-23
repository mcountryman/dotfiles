#!/usr/bin/env sh

while true;
  swaymsg "output * bg "(find $wallpapers_path -type f | shuf -n 1)" fill"; 
  sleep 1;
end