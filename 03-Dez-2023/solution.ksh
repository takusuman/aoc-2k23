#!/usr/bin/env ksh93
#
# The engine schematic (your puzzle input) consists of a visual representation of the engine.
# There are lots of numbers and symbols you don't really understand, but apparently any number
# adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum.
#

function main {
	# Make eschembuf public, we will need to access it directly on the
	# solution.
	typeset -a -x eschembuf
	# Sum of engine scheme numbers, number of lines and line number (for
	# buffer index).
	integer eschemsum nl s num sum

	# Same ol' code from the first day.
	# Nothing new to see here, chap.
	for (( nl=0; ; nl++ )); do
		if read line; then
			eschembuf[$nl]="$line"
		else
			break
		fi
	done

	.part.one eschembuf | read sum
	print -f 'The sum of all part numbers in the engine schematic: %d\n' $sum

}

namespace part {
	function one {
		# Some tracing for testing.
		#set -x
		# Matrix buffer, since our schematic is a matrix.
		nameref mbuf="$1"
		integer l c p sum startnum stopnum
		for (( l=0; l<${#mbuf[@]}; l++ )); do
			line.previous="${mbuf[$(( l - 1 ))]}"
			line.current="${mbuf[$l]}"
			line.next="${mbuf[$(( l + 1 ))]}"
			# Just a simple sanity test.
			# print 1>&2 -f 'line.previous: %s\nline.current: %s\nline.next: %s\n' \
			#       	${line.previous:-"nil"} ${line.current} ${line.next:-"nil"}

			for (( c=0; c<${#line.current}; c++ )); do
				scchr=${line.current:$c:1}
				if [[ "$scchr" == +([0-9]) ]] && \
					(( c < (${#line.current} - 1))); then
					# We will later pass this to a integer.
					numstr+="$scchr"
				elif (( ${#numstr} >= 0 )); then
					if [[ "$scchr" == +([0-9]) ]] \
					&& (( c == (${#line.current} - 1) )); then
						numstr+="$scchr"
					fi
					((startnum= c - (${#numstr} + 1) ))
					# Well, we don't have ternaries here.
					(( startnum < 0 )) && startnum=0
					((stopnum= c + 1 ))
					# Create a unified string with the
					# previous, current and next line on
					# this matrix, then remove dots and
					# digits from it in search of symbols.
					lines=(previous current next)
					for (( s=2; s<${#lines[@]}; s++ )); do
						for ((c=startnum; c<(stopnum - startnum); c++)); do
							print -f '%c' "$(print -f '${line.%s:$c:1}' ${lines[$s]})"
						done
					done | read onetwotree
					for (( p=0; p<${#onetwothree}; p++ )); do
						pc="${onetwothree:$p:1}"
						if [[ "$pc" != +([0-9]) || "$pc" != "." ]]; then
							pattern+="$pc"
						else
							continue
						fi
					done
					if (( ${#pattern} > 0 )); then
						sum+=$(( numstr ))
					fi
				fi
				unset scchr startnum stopnum onetwothree numstr
			done
		done
		print -f '%d' "$sum"
	}

	function two {
		return 0 
	}
}

namespace strings {
# That's specific for summing three strings, counting with the fact that the
# start and stop of the string will be positive
function sum {
	integer from=$1 to=$2 s

	for (( s=2; s<${#}; s++ )); do
		final_string+=$(substring ${!s} $from $to)
	done
	print -f '%s' "$final_string"
}

function substring {
	set -x
	nameref string_identifier="$1"
	from="$2"
	to="$3"
	for ((c=from; c<to; c++)); do
		print -f '%c' "${string_identifier:$c:1}"
	done
}

}

main
