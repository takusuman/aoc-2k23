#!/usr/bin/env ksh93
# Solution for the Day 2 of AoC 2k23.
# https://adventofcode.com/2023/day/2

# "The Elf would first like to know which games would have been possible
# if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?"

function main {
	# First of all, copy our games from its file to the memory.
	typeset -a gamefbuf
	# Number of lines, string number and calibration sum.
	integer nl p3gamesum
	
	# Same ol' code from the first day.
	# Nothing new to see here, chap.
	for (( nl=0; ; nl++ )); do
		if read line; then
			gamefbuf[$nl]="$line"
		else
			break
		fi
	done
	
	for ((g=0; g<${#gamefbuf[@]}; g++)); do
		.part.one "${gamefbuf[$g]}" | read result 
		if ! [[ $result =~ (x) ]]; then
			# Since the game number starts from 1 and our array
			# starts from 0, nothing more just than just adding 1 to
			# our array index to get the game ID.
			# If it was generated haphazardly, it would be a
			# completely different history.
			p3gamesum+=$((g+1))
		else
			continue
		fi
	done
	print -f 'The sum of the possible games ID: %d\n' $p3gamesum
}

namespace part {
	function one {
		#set -x
		s="$1"
		integer c ngame nmain m mc cubecolour uptotwodots 

		# I think I will need to record each game per ID in a, let's
		# say, Google Go language-like "map".
		# Keep in mind that "main" here doesn't refer to a principal
		# part of something, yet to "main" in the sense of a match in a
		# game of dice, what kind of makes sense here.
		#
		# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
		# game[1]+=(main[1]=(blue=3 red=4) main[2]=(red=1 green=2 blue=6) main[3]=(green=2))

		# "The Elf would first like to know which games would have been possible
		# if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?"
		p3game=(blue=14; green=13; red=12)

		# Game number ->  ${line:5:1}
		ngame="${s:5:1}"

		# Well, remember when I said that it would be just 8 characters
		# from "Game N: " to the game content itself? I erred!
		# This time, we will be counting using a C-style for loop until
		# we stump in a two-dot.
		# So, now, consider n characters from "Game N: " to its contents:
		#c 1,2,3,4,5,.,.,(n-1),n
		#s"G,a,m,e, ,n,n,:, "
		for ((uptotwodots=0; ; uptotwodots++)); do
			if [[ "${s:$uptotwodots:1}" == ':' ]]; then
				break
			fi
		done

		for ((c=uptotwodots; c < ${#s}; c++)); do
			# String current character.
			scchr="${s:$c:1}"
			# If, by accident, some ":" get on the way.
			# Well, also forgot the fact that we will exceed 3-digit
			# numbers.
#			if [[ "$scchr" == ':' ]]; then
#				continue
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
		
		# Quick n' dirty hack
		# We can already see where this is going.
		OLDIFS=$IFS
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
		unset pgame[$ngame].main
		
		# O/P
		# Number of said ocorrences and number of possible games.
		# The maximum factor for this is 1, more than that is
		# a impossible game, less or 0 is a possible game --- zero
		# because no cube was taken.
		# Source: https://online.stat.psu.edu/stat200/lesson/2/2.1/2.1.3/2.1.3.1
		cube_colours=('blue' 'green' 'red')
		for ((m=0; m < ${#game[$ngame].main[@]}; m++)); do
			for ((cubecolour=0; cubecolour<${#cube_colours[@]}; cubecolour++)); do
				current_main=$(eval echo \${game[$ngame].main[$m].${cube_colours[$cubecolour]}})
				expected_main=$(eval echo \${p3game.${cube_colours[$cubecolour]}})	
				if [[ -z $current_main ]]; then
					current_main=1
				fi
				p=$(P $current_main $expected_main)
				if (( p > 1 || 0 > p )); then
					impossible=true
				fi
			done
			if ! ${impossible:-false}; then
				# "Main n of game m is possible."
				res+='v'
			else
				# "Main n of game m is impossible."
				res+='x'
			fi
			unset impossible
		done 

		print -f '%s' "$res"
	}

	function two {
		print 1>&2 -f \
		'Probably there will be a part two, so keep your eyes open.\n'
		exit 1
	}

}

function P {
	integer	ocurrencies="$1" possible="$2"
#	eval print -f '%.10f' $(print -f '$(( %d/%d. ))' $ocurrencies $possible)
	# Gotta hate this variable syntax, but it's the best we can do with out
	# doing juggling with eval.
	print -f '%.10f' $(( ${ocurrencies}/${possible}. ))
}

main 
