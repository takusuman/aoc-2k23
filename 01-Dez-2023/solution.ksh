#!/usr/bin/env ksh93
# Solution for the Day 1 of AoC 2k23.
# https://adventofcode.com/2023/day/1

function main {
	# First of all, copy our calibration numbers from its file to the memory.
	typeset -a cfbuf
	# Number of lines, string number and calibration sum.
	integer nl sn csum

	for (( nl=0; ; nl++ )); do
		if read line; then
			# Advice of the day: if you want to implement a file
			# reader in, let's say, shell and doesn't want to call
			# sed from the disk just to cut off some blank lines,
			# then just do this.
			# I will not be doing it since AoC's file doesn't
			# contain any blank line, so I will opt for saving CPU
			# operations.
			#if [[ ! -n "$line" ]]; then
			#	continue
			#fi
			cfbuf[$nl]="$line"
		else
			break
		fi
	done

	# This was just a checker to see if everything was duly copied from the
	# file to an array.
	#print -C cfbuf

	for ((sn=0; sn<nl; sn++)); do
		# print -f 'String: %s\n' ${cfbuf[$sn]} 1>&2
		((csum= csum + $(.part.one ${cfbuf[$sn]})))
		#((csum= csum + $(.part.two ${cfbuf[$sn]})))
	done

	print -f 'Calibration sum: %d\n' $csum
}

namespace part {
	function one {
		# Character number, string and string length
		integer c sl
		s="$1"
		sl=${#s}

		# First, let's make our alfanumeric string into a number string,
		# so it's get easier to encounter the first and last numbers.
		nstr=''
		for ((c=0; c<sl; c++)); do
			cchr=${s:$c:1}
			if [[ $cchr != +([0-9]) ]]; then
				continue
			fi
			nstr+=${s:$c:1}

			unset cchr
		done
		# First: ${nstr:0:1}
		# Last: ${nstr: -1:1}
		print -f '%d%d' ${nstr:0:1} ${nstr: -1:1}
	}
	function two {
		# Input string.
		s="$1"

		# Map numbers in full lenght as numerals from 1 to 9 using
		# a vulgar array.
		typeset -a spelltonum[9]
		spelltonum[1]=one
		spelltonum[2]=two
		spelltonum[3]=three
		spelltonum[4]=four
		spelltonum[5]=five
		spelltonum[6]=six
		spelltonum[7]=seven
		spelltonum[8]=eight
		spelltonum[9]=nine
		
		# This entire part just does not give the right value, I do not
		# know why.
		
		# Then, we also need some order because of some tomfool strings
		# such as "xtwone3four".
		typeset -a orderandprogress
		orderandprogress=(9 8 7 6 5 4 3 2 1)
		
		print -f '%s' "$s" \
		| sed -e "$(for ((m=0; m<${#orderandprogress}; m++)); do
			print -f 's/%s/%d/g; ' ${spelltonum[${orderandprogress[$m]}]} ${orderandprogress[$m]}
		done)" | read string
		
		# Call part one function from inside the same namespace.
		one $string

		return 0
	}
}

main $@
