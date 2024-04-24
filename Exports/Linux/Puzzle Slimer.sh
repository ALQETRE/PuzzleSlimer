#!/bin/sh
echo -ne '\033c\033]0;Puzzle Slimer\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Puzzle Slimer.x86_64" "$@"
