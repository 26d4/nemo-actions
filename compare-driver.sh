#!/bin/sh

set -eu

SAVE="$XDG_RUNTIME_DIR"/compare-select

case "$1" in
	can-select)
		{
			[ ! -e "$SAVE" ] ||
			[ ! -e "$(cat "$SAVE")" ]
		} &&
		grep -qIF '' "$2"
		exit
		;;
	can-compare)
		[ -e "$SAVE" ] &&
		[ -e "$(cat "$SAVE")" ] &&
		grep -qIF '' "$2"
		exit
		;;
	can-clear)
		[ -e "$SAVE" ]
		exit
		;;
	select)
		echo "$2" > "$SAVE"
		;;
	compare)
		meld "$(cat "$SAVE")" "$2"
		exec "$0" clear
		;;
	clear)
		rm "$SAVE"
		;;
	*)
		exit 2
		;;
esac