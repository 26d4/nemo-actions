#!/usr/bin/env bash

case "$2" in
	sftp*)
		CONN=$(cut -d'/' -f3 <<< "$2")
		TARGET=$(findmnt -T "$1" -no TARGET)
		DIR="${1#"$TARGET"}"
		DIR="/$(cut -d'/' -f3- <<< "$DIR")"
		;;
	file*)
		CONN=$(findmnt -T "$1" -no SOURCE)
		CONN="${CONN%:}"
		TARGET=$(findmnt -T "$1" -no TARGET)
		DIR="${1#"$TARGET"}"
		DIR="${DIR#/}"
		;;
	*)
		exit 125
esac

ssh "$CONN" -t "cd \"$DIR\" && exec \$SHELL -l" || read -n1 -p "ssh exited with code $?"