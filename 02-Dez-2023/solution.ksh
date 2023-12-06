#!/usr/bin/env ksh93
# Solution for the Day 2 of AoC 2k23.
# https://adventofcode.com/2023/day/2

function main {
	# First of all, copy our games from its file to the memory.
	# We will also be setting an array that memoizes the position
	# of which games were possible, so we won't be needing to go
	# through the gamefbuf array again.
#	typeset -a gamefbuf p3gamespos
	typeset -a gamefbuf	
	# Since both the part one and two uses the cube_colors array, I will be
	# making it public.
	typeset -a -x cube_colours
	cube_colours=('blue' 'green' 'red')

	# Number of lines, string number and calibration sum.
	integer nl p3gamesum p3gameminsum
	
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
		part_one "${gamefbuf[$g]}" | read result 
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
		ret=$(part_two "${gamefbuf[$g]}")
		p3gameminsum+=$(( $ret ))
	done
	print -f 'The sum of the possible games ID: %d\n' $p3gamesum
	print -f 'The sum of the power of the minimum numbers for possible games: %d\n' $p3gameminsum

}

function part_one {
	set -x
	s="$1"
	integer c nmain m mc cubecolour uptotwodots 

	# I think I will need to record each game per ID in a, let's
	# say, Google Go language-like "map"... Or better, a Pascal "record".
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
	#ngame="${s:5:1}"
	# Getting the game number utilizing pure POSIX stubborness, just because
	# I want to save for loops.
	_ngame=${s%%:*}
	ngame=${_ngame##Game }
	unset _ngame

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
	done; uptotwodots=$((uptotwodots + 1))

	for ((c=uptotwodots; c < ${#s}; c++)); do
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

function part_two {
	s=$1

	# "As you continue your walk, the Elf poses a second question:
	# in each game you played, what is the fewest number of cubes of
	# each color that could have been in the bag to make the game possible?"
	# Godon elf.
	grandest_main=(blue=0; green=0; red=0)

	# All that parsing again, I will not be wasting time to separate
	# this in a single function.
	# I could pretty much memoize much of these, but I won't do it
	# for now because I would have to rewrite almost everything.
	_ngame=${s%%:*}
	ngame=${_ngame##Game }
	unset _ngame
	for ((uptotwodots=0; ; uptotwodots++)); do
		if [[ "${s:$uptotwodots:1}" == ':' ]]; then
			break
		fi
	done; uptotwodots=$((uptotwodots + 1))
	if (( ngame == 5 )); then
		print 1>&2 -f 'uptotwodots: %d\n' $uptotwodots
	fi

	for ((c=uptotwodots; c < ${#s}; c++)); do
		scchr="${s:$c:1}"
		if [[ "$scchr" != ';' ]]; then
			pgame[$ngame].main[$nmain]+="$scchr"
		else
			nmain=$((nmain + 1))
		fi
	done
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
	# End of parsing, 27 lines repeated. Grand.
	
	# Now we shall iter in on each main of this game to see which are the
	# grandest numbers.
	for ((m=0; m < ${#game[$ngame].main[@]}; m++)); do
		for ((cubecolour=0; cubecolour<${#cube_colours[@]}; cubecolour++)); do
			current_main_value=$(eval echo \${game[$ngame].main[$m].${cube_colours[$cubecolour]}})
			nameref previous_main_value="grandest_main.${cube_colours[$cubecolour]}"
			if (( current_main_value > previous_main_value )); then
				previous_main_value=$current_main_value
			fi
		done
	done

	ret=$(( ${grandest_main.blue} * ${grandest_main.green} * ${grandest_main.red} ))
	print -f '%d' $ret
}

# O/P
# Number of said ocorrences and number of possible games.
# The maximum factor for this is 1, more than that is
# a impossible game, less or 0 is a possible game --- zero
# because no cube was taken.
# Source: https://online.stat.psu.edu/stat200/lesson/2/2.1/2.1.3/2.1.3.1
function P {
	integer	ocurrencies="$1" possible="$2"
#	eval print -f '%.10f' $(print -f '$(( %d/%d. ))' $ocurrencies $possible)
	# Gotta hate this variable syntax, but it's the best we can do with out
	# doing juggling with eval.
	print -f '%.10f' $(( ${ocurrencies}/${possible}. ))
}

main 
