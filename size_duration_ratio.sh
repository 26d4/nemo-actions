#!/usr/bin/env bash

declare -a FILES

while (( $# > 0 )); do
	if [[ -d "$1" ]]; then
		mapfile -d $'\0' FILES_ADD < <(find "$1" -mindepth 1 -maxdepth 1 -print0 -type f)
		FILES+=("${FILES_ADD[@]}")
	else
		FILES+=("$1")
	fi
	shift
done

set -- "${FILES[@]}"

FIFO=$(mktemp -u --tmpdir "$$-XXXX")
mkfifo "$FIFO"

tail -f "$FIFO" | zenity --progress --auto-close --auto-kill --width=500 &

TEXT=$(
	i=0
	for f in "$@"; do
		echo "$((i*100/$#))" >> "$FIFO"
		echo "# $f" >> "$FIFO"
		ffprobe -v quiet -of default=nk=1:nw=1 -show_entries format=duration,size "$f" || continue
		basename "$f"
		echo
		i=$((i+1))
	done | awk -v FS='\n' -v RS='' '{printf "%d %s\n", $2/$1, $3}' | sort -n
)

echo 100 >> "$FIFO"

rm -f "$FIFO"
zenity --text-info --title="Size to duaration ratio" --font=monospace --width=600 --height=600 --no-wrap <<< "$TEXT"
