#!/usr/bin/env bash

select_target_format() {
	ffmpeg -v quiet -muxers \
		| awk '{system("ffmpeg -hide_banner -h muxer="$2); print ""}' \
		| awk -v RS='' '/extensions:.*Mime type: +(video|audio)/' \
		| awk '/^Muxer/{print $2; print $0} /extensions:/{print $3} /Mime type:/{print $3; print ""}' \
		| sed -e '/\[.*\]/{ s/^.*\[//; s/\].*// }' -e '/\[.*\]/! { s/,.*//; s/\.// }' \
		| awk -v RS='' -v FS='\n' '{print "FALSE", $1, $3, $4, "\""$2"\""}' \
	| xargs zenity --list --radiolist \
		--width=640 --height=480 \
		--text="Select target format" \
		--column=_ --column=Muxer --column=Ext. --column=Type --column=Description
}

muxer_ext() {
	ffmpeg -v quiet -h muxer="$1" | awk '/Common extensions:/{print $3}' | sed -e 's/,.*//' -e 's/\.//'
}

MUXER=$(select_target_format)
[[ -n "$MUXER" ]] || exit 0

ffmpeg -i "$1" -f "$MUXER" "${1%.*}.$(muxer_ext "$MUXER")"