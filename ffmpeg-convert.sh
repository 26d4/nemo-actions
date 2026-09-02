#!/usr/bin/env bash

CACHE="${XDG_CACHE_HOME-$HOME/.cache}/ffmpeg-convert"
MUXCACHE="$CACHE/muxers"
FFVER="$CACHE/ffmpeg-version"

mkdir -p "$CACHE"

get_muxers() {
	if
		[[ -z "$(find "$MUXCACHE" -maxdepth 0 -type f -mtime -30 '!' -empty)" ]] ||
		[[ ! -e "$FFVER" ]] ||
		[[ "$(ffmpeg -version)" != "$(cat "$FFVER")" ]]
	then
		ffmpeg -v quiet -muxers \
		| awk '{system("ffmpeg -hide_banner -h muxer="$2); print ""}' \
		| awk -v RS='' '/extensions:.*Mime type: +(video|audio)/' \
		| awk '/^Muxer/{print $2; print $0} /extensions:/{print $3} /Mime type:/{print $3; print ""}' \
		| sed -e '/\[.*\]/{ s/^.*\[//; s/\].*// }' -e '/\[.*\]/! { s/,.*//; s/\.// }' \
		| tee "$MUXCACHE" | zenity --progress --pulsate --no-cancel --auto-close --text="Generating muxer cache"

		ffmpeg -version > "$FFVER"
	fi

	cat "$MUXCACHE"
}

select_target_format() {
	get_muxers | awk -v RS='' -v FS='\n' '{print "FALSE", $1, $3, $4, "\""$2"\""}' \
	| xargs zenity --list --radiolist \
		--width=640 --height=480 \
		--text="Select target format" \
		--column=_ --column=Muxer --column=Ext. --column=Type --column=Description
}

muxer_ext() {
	get_muxers | awk -v RS='' -v FS='\n' '$1 == "'"$1"'"{print $3}'
}

MUXER=$(select_target_format)
[[ -n "$MUXER" ]] || exit 0

ffmpeg -i "$1" -f "$MUXER" "${1%.*}.$(muxer_ext "$MUXER")" || read -n1 -ppaused