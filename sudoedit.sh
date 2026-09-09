#!/bin/bash
FILEOWNER=$(stat -c %U "$1")
if [ "$FILEOWNER" = "$USER" ]; then
	xdg-open "$1"
else
#	export SUDO_EDITOR="xed -w"
#	export SUDO_ASKPASS="$HOME/.local/share/nemo/actions/zenity_askpass.sh"  
#	OUTPUT="$(sudoedit -A -u "$FILEOWNER" "$1" 2>&1)"
#	notify-send -e "$OUTPUT"

	URI="admin:${2#*:}"

	xed "$URI"
fi
