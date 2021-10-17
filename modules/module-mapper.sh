#! /bin/bash

set -eux

repo=gcm.cache

input="$1"
output="$(basename "$input")".ii
coproc compiler (c++ -E -fdirectives-only -std=c++23 -fmodules-ts -fmodule-mapper='<>' -xc++ "$input" -o"$output")

{
	while read request
	do
		printf '> %s\n' "$request" >&2
		if [[ "$request" =~ \ \;$ ]]
		then
			more=' ;'
		else
			more=
		fi
		case "$request" in
			('INCLUDE-TRANSLATE '*)
				printf 'BOOL TRUE%s%s\n' "$more"
				;;
			('MODULE-IMPORT '*)
				args=($request)
				"$0" ${args[1]}
				printf '>< %s\n' "$request" >&2
				printf 'PATHNAME %s%s\n' ',/'"$(basename "${args[1]}")".ii.gcm "$more"
				;;
			('HELLO 1 '*';')
				printf 'HELLO 1 %s%s\n' "$(basename "$0")" "$more"
				;;
			('HELLO '*)
				printf 'ERROR protocol version not supported: %s\n' "$request" | tee /dev/stderr
				exit 1
				;;
			('MODULE-REPO')
				printf 'PATHNAME %s%s\n' "$repo" "$more"
				;;
			(*)
				printf 'ERROR unknown request: %s\n' "$request" | tee /dev/stderr
				exit 1
		esac
	done
} <&${compiler[0]} >&${compiler[1]}

input="$output"
output="$(basename "$input")".gcm
c++ -c -fmodule-header -std=c++23 -fmodules-ts -xc++ "$input"
