
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

	.part.one cardfbuffer

}

namespace part {
	function one {
		nameref cardfbuffer="$1"
		integer i j k l n winnum separator_pos cardnum matchnum matchsum 
		typeset -a cards
		
		# This entire part just separes the winning numbers from the
		# rest of the cards itself. 
		for ((l=0; l<${#cardfbuffer[@]}; l++)); do
			string="${cardfbuffer[$l]}"
			card_separator_pos="$(.strings.uptochar "$string" ':')"
			separator_pos="$(.strings.uptochar "$string" '|')"
			# Card number
			_ncard=${string%%:*}
			ncard=${_ncard##Card }
			unset _ncard
			# Number of numbers in the card, it will be used in the
			# card[][] array. Also there's the number of winning
			# numbers per card
			cardnum=0
			winnum=0
			for (( n=card_separator_pos; n < separator_pos; n++ )); do
				numchr="${string:n:1}"
				if [[ "$numchr" == +([0-9]) ]]; then
					eval $(printf 'cards[%d][%d]+=%s' $ncard $cardnum "${string:n:1}")
				elif [[ "$numchr" == [[:space:]] ]]; then
					((cardnum+= 1))
					continue
				fi
			done; unset numchr

			for (( n=separator_pos; n < ${#string}; n++ )); do
				numchr="${string:n:1}"
				if [[ "$numchr" == +([0-9]) ]]; then
					eval $(printf 'cards[%d].winning[%d]+=%s' $ncard $winnum "${string:n:1}")
				elif [[ "$numchr" == [[:space:]] ]]; then
					if [[ "${string:$((n + 1)):1}" == [[:space:]] ]]; then
						continue
					fi
					((winnum+= 1))
					continue
				fi
			done
		done 
		
		for ((i=1; i<=${#cards[@]}; i++)); do
			cards[i].match=0
			integer matches=0
			nameref matchnum=cards[i].match
			nameref matchchrs=cards[i].matchchrs
			for ((k=1; k<=${#cards[i][@]}; k++)); do
				for ((j=1; j<=${#cards[i].winning[@]}; j++)); do
					if [[ "${cards[i][k]}" == "${cards[i].winning[j]}" ]]; then
						if [[ -z "${cards[i][k]}" \
						|| -z "${cards[i].winning[j]}" ]]; then
							continue
						fi
						# 'R' stands for "Rendezvous",
						# since we will be having two
						# values rendezvouing.
						matchchrs+='R'
					fi	
				done
			done
			matches=${#matchchrs}
			((matchnum= 1 * (2 ** (matches - 1)) ))
			# Unset the temporary variable, then the nameref.
			unset matches matchchrs 
			unset -n matchnum 
		done

		print -v cards
		for ((m=1; m <= ${#cards[@]}; m++ )); do
		       printf 1>&2 'cards[%d].match: %d\n' ${m} ${cards[m].match}
		       ((matchsum+= ${cards[m].match}))
	       	done
		printf 1>&2 'The sum of all the matches: %d\n' $matchsum
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
		nameref string_identifier="$1"
		from="$2"
		to="$3"
		for ((c=from; c<to; c++)); do
			s+="${string_identifier:$c:1}"
		done
		printf '%s' "$s"
	}

	# Borrowed from herbiec.
	function isdigit {
		typeset digit=$1
		[[ $(printf '%d' $digit) == $digit \
			&& $digit == +([0-9]) ]] || return 1
	}
}

main
