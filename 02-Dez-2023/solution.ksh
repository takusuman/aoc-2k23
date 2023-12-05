#!/usr/bin/env ksh93
# Solution for the Day 2 of AoC 2k23.
# https://adventofcode.com/2023/day/2

# "The Elf would first like to know which games would have been possible
# if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?"

function main {
	# First of all, copy our games from its file to the memory.
	typeset -a gamefbuf
	# Number of lines, string number and calibration sum.
	integer nl
	
	# Same ol' code from the first day.
	# Nothing new to see here, chap.
	for (( nl=0; ; nl++ )); do
		if read line; then
			gamefbuf[$nl]="$line"
		else
			break
		fi
	done
	.part.one "${gamefbuf[0]}"
}

namespace part {
	function one {

		s="$1"
#		integer c ngame nmain m mc cc	
		integer c ngame nmain m mc

		# I think I will need to record each game per ID in a, let's
		# say, Google Go language-like "map".
		# Keep in mind that "main" here doesn't refer to a principal
		# part of something, yet to "main" in the sense of a match in a
		# game of dice, what kind of makes sense here.
		#
		# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
		# game[1]+=(main[1]="blue=3 red=4" main[2]="red=1 green=2 blue=6" main[3]="green=2")
		# Game number ->  ${line:5:1}
		# 8 characters from "Game X: " to its contents
		# 12345678
		# 'Game X: '
		#
	
		ngame="${s:5:1}"

		# 8 characters from "Game X: " to its contents:
		#c 12345678
		#s"Game X: "
		# But we will start reading it from the 7th.
		for ((c=7; c < ${#s}; c++)); do
			# String current character.
			scchr="${s:$c:1}"
			if [[ "$scchr" != ';' ]]; then
				# "pgame" means something like "proto-game", it
				# will contain the unparsed mains, but it will
				# be a reference for later transmuting it into
				# a compound variable again.
				pgame[$ngame].main[$nmain]+="$scchr"
			else
				nmain=$((nmain + 1))
			fi
		done
		
		print -C pgame[$ngame].main
		print -v pgame[$ngame].main
		print ${#pgame[$ngame].main[@]}

		# Quick n' dirty hack
		# We can already see where this is going.
		OLDIFS=$IFS
		set -x
		for ((m=0; m < ${#pgame[$ngame].main[@]}; m++)); do 
			print -f '%s' "${pgame[$ngame].main[$m]}" \
			| tr ',' '\n' \
			| for ((;;)); do
				if read cube || [[ -n $cube ]] ; then
					eval $(print -f 'typeset game[%d].main[%d].%s=%d' \
					       	$ngame $m "${cube##* }" "${cube%% *}")
				else
					break
				fi
			done
		done
		IFS="$OLDIFS"

		print -C game[$ngame].main
		# "The Elf would first like to know which games would have been possible
		# if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?"

	
		# My previous solution that wasn't fully working
		# A shame, really.
#		for ((m=0; m < nmain; m++)); do 
#			for ((mc=0; mc<${#pgame[$ngame].main[$m]}; mc++ )); do
#				mainc="${pgame[$ngame].main[$m]:$mc:1}"
#				ee=0
#				if [[ "$mainc" == ',' || -z "$mainc" ]]; then
#					for ((cc=ee; cc<c; cc++)); do
						# This probably shall be the
						# cube colour with the number of
						# times it appeared on the Elf's main.
#						cubec="${pgame[$ngame].main[$m]:$cc:1}"
#						if [[ "$cubec" == [[:space:]] \
#						|| "$cubec" == ',' ]] ; then
#							ee=$cc		
#							continue
#				      		elif [[ "$cubec" == +([0-9]) ]]; then
#							v+="$cubec"
#						else
#							id+="$cubec"
#						fi
#					done
#
#					eval $(printf 'game[%d].main[%d].%s=%d' $ngame $m "$id" "$v")
#					unset mainc cubec id v
#				fi
#			done
#		done

	}

	function two {
		print 1>&2 -f \
		'Probably there will be a part two, so keep your eyes open.\n'
		exit 1
	}

}

main 
