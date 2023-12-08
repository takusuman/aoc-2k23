
function main {
	# Make it public, we will need it on part one function.
	# Gone are the times where we could simply pipe part one function into
	# part two.
	typeset -a -x cardfbuffer
	# Hell yeah, liberté.
	for (( nl=0; ; nl++ )); do
		if read s; then
			cardfbuffer[$nl]="$s"
		else
			break
		fi
	done

#	print -v cardfbuffer
	.part.one cardfbuffer

}

namespace part {
	function one {
		nameref cardfbuffer="$1"
		integer l n winnum separator_pos cardnum
		set -x
		typeset -a winning cards
		# This entire part just separes the winning numbers from the
		# rest of the cards itself. 
		for ((l=0; l<${#cardfbuffer[@]}; l++)); do
			string="${cardfbuffer[$l]}"
			separator_pos="$(.strings.uptochar "$string" '|')"
			for (( n=separator_pos; n < ${#string}; n++ )); do
				numchr="${string:n:1}"
				if [[ "$numchr" == [[:space:]] ]]; then
					printf '\n'
				else
					printf '%c' "${string:n:1}"
				fi
			done 
		done | sort -u \
		| for (( n=0; ; n++ )); do
			if read winnum; then
				winning+=( $winnum )
			else
				break
			fi
		done

		for ((l=0; l<${#cardfbuffer[@]}; l++)); do
			string="${cardfbuffer[$l]}"
			card_separator_pos="$(.strings.uptochar "$string" ':')"
			separator_pos="$(.strings.uptochar "$string" '|')"
			# Card number
			_ncard=${string%%:*}
			ncard=${_ncard##Card }
			unset _ncard
			# Number of numbers in the card, it will be used in the
			# card[][] array.
			cardnum=0
			for (( n=card_separator_pos; n < separator_pos; n++ )); do
				numchr="${string:n:1}"
				if [[ "$numchr" == +([0-9]) ]]; then
					set -x
					eval $(printf 'cards[%d][%d]+=%s' $ncard $cardnum "${string:n:1}")
				elif [[ "$numchr" == [[:space:]] ]]; then
					((cardnum+= 1))
					continue
				fi
			done
		done 
		
		print -C winning
		print -C cards
	}
}

namespace strings {
	function uptochar {
		integer u
		string="$1"
		char="$2"
		
		for ((u=0; ; u++)); do
			[[ "${string:u:1}" \
			== "$(printf '%c' "$char")" ]] \
			&& break 
		done
		# Sum one, since ${string:u:1} indicates not exactly the
		# position where the wanted characther is, yet counting one from
		# where we ended up.
		u+=$(( 1 ))

		printf '%d' $u
	}

	function substring {
		set -x
		nameref string_identifier="$1"
		from="$2"
		to="$3"
		for ((c=from; c<to; c++)); do
			printf '%c' "${string_identifier:$c:1}"
		done
	}

	# Borrowed from herbiec.
	function isdigit {
		typeset digit=$1
		[[ $(printf '%d' $digit) == $digit \
			&& $digit == +([0-9]) ]] || return 1
	}
}

main
