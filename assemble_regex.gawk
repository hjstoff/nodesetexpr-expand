#! /usr/bin/gawk -bf

function check_parentheses(regexstr,	n, i, leftcount, rightcount, last) {
#
# Return 0 if no unbalanced parenthesis detected in regexstr, otherwise return
# the character position at which unbalance has been detected in regexstr.
# Limitation:
# The function does not take the possibility of escaping of parentheses
# into account.
#
	n = length(regexstr);
	leftcount = rightcount = last = 0;
	for (i = 1; i <= n; ++i) {
		if (substr(regexstr, i, 1) == "(") {
			++leftcount;
			if (leftcount <= rightcount) {
				return i;
			}
			last = i;
		}
		else if (substr(regexstr, i, 1) == ")") {
			++rightcount;
			if (leftcount < rightcount) {
				return i;
			}
			last = i;
		}
	}
	if (leftcount != rightcount) {
		return last;
	}
	return 0;
}

function count_parentheses(regexprstr,		n, i) {
#
# Return the number of (left) parentheses found in regexprstr.
# If parentheses are balanced, this is equal to the number of 
# parentheses pairs, and so to the number of submatches that can be
# captured by the match function.
# Limitation:
# The function does not take the possibility of escaping of parentheses
# into account.
#
	n = length(regexprstr);
	leftcount = 0;
	for (i = 1; i <= n; ++i) {
		if (substr(regexprstr, i, 1) == "(") {
			++leftcount;
		}
	}
	return leftcount; 
}

function show_submatches(s, regexprstr, submatch,	i, n) {
#
# Try to match s against regexprstr, using gawk's  built-in match function.
# If submatch is not a local variable, but passed to the function,
# it must be passed as an array or as a variable yet to be defined.
# On return, any previous contents of submatch is destroyed and submatch
# contains all submatches.
# On no match, nothing is printed, and the function returns -1.
# On match the number of submatches is returned, which can be 0, if the
# regular expression defines no submatches.
#
	if (match(s, regexprstr, submatch)) {
		n = count_parentheses(regexprstr);
		for (i = 0; i <= n; ++i) {
			if (i in submatch) {
				printf("submatch %2d, start %d, length %d: %s\n",
					i,
					submatch[i, "start"],
					submatch[i, "length"],
					submatch[i]);
			}		
		} 
		return n;
	}
	else {
		return -1;
	}
}

BEGIN {
	#
	# namech, character that can be validly used in a nodename,
	# but not necessarily as the first character. It is debatable
	# whether the underscore should be included.
	#
	namech = "[A-Za-z0-9_-]";
	printf("%s: /^%s$/\n", "namech", namech);
	
	#
	# namech1, character that can be validly used as the first
	# character of a nodename (or DNS domain label). It is debatable
	# whether the underscore should be included.
	#
	namech1 = "[A-Za-z0-9_]";
	printf("%s: /^%s$/\n", "namech1", namech1);

	#
	# nameinfix_lit, string of on or more literals that can be
	# an infix in a name.
	#
	nameinfix_lit = namech "+";
	printf("%s: /^%s$/\n", "nameinfix_lit", nameinfix_lit);

	#
	# nameprefix_lit, string of on or more literals that can be
	# a the prefix of a name.
	#
	nameprefix_lit = namech1 namech "*";
	printf("%s: /^%s$/\n", "nameprefix_lit", nameprefix_lit);

	#
	# A number is zero or a natural number. A number can be written
	# using a prefix of numerically redundant "padding" zeroes.
	#
	number = "[0-9]+";
	printf("%s: /^%s$/\n", "number", number);

	#
	# A nonzero_number is is a natural number that is cannot
	# be written using a prefix of numerically redundant zeroes.
	#
	nonzero_number = "[1-9][0-9]*";
	printf("%s: /^%s$/\n", "nonzero_number", nonzero_number);

	#
	# opt_sign, an optional sign, is a plus or a minus. Without
	# the sign, a following nonzero_number is interpreted as 
	# positive.
	#
	opt_sign = "[+-]?";
	printf("%s: /^%s$/\n", "opt_sign", opt_sign);

	#
	# numstrset_elem, a number string set element, which is
	# either a number or a range defined by two numeric bounds
	# that can have zero-padded values, and optionally has a
	# stride specification.
	# Note that the slash literal is escaped by a backslash.
	# This is because in awk a regular expression constant is
	# enclosed in slashes. If the slash is not escaped it will
	# be interpreted as the end of the regular expression.
	# Note that 2 backslashes are required to put a backslash
	# effectively into the string.
	#
	numstrset_elem = number "(-" number "(\\/" opt_sign nonzero_number ")?)?"; 
	printf("%s: /^%s$/\n", "numstrset_elem", numstrset_elem);
	if ((pos = check_parentheses(numstr_elem)) > 0) {
		printf("Unbalanced parentheses detected, position %d\n!", pos);
	}

	#
	# numstrset, set of one or more comma-separated nmberset elements.
	# The numbestring set is enclosed in square brackets, as square brackets
	# have a meaning in regular expression as character class operators
	# too. Note that 2 backslashes are required to put a backslash
	# effectively into the string.
	#
	numstrset = "\\[" numstrset_elem "(," numstrset_elem ")*\\]";
	printf("%s: /^%s$/\n", "numstrset", numstrset);
	if ((pos = check_parentheses(numstrset)) > 0) {
		printf("Unbalanced parentheses detected, position %d\n!", pos);
	}
	
	# short_namepattern, pattern for a short nodename (no domain suffix).
	short_namepattern = "(" nameprefix_lit "|" numstrset ")(" nameinfix_lit "|" numstrset ")*";
	printf("%s: /^%s$/\n", "short_namepattern", short_namepattern);
	if ((pos = check_parentheses(short_namepattern)) > 0) {
		printf("Unbalanced parentheses detected, position %d\n!", pos);
	}

	#
	# name_pattern, general name pattern for a short nodename or nodename
	# with a suffix domain labels. 
	#
	namepattern = short_namepattern "([.]" short_namepattern ")*";
	printf("%s: /^%s$/\n", "namepattern", namepattern);
	if ((pos = check_parentheses(namepattern))a > 0) {
		printf("Unbalanced parentheses detected, position %d\n!", pos);
	}

	#
	# Note that the first namepattern and the "rest" that follow (may be
	# none) both are in an extra pair of parentheses for easy capturing
	# these 2 as submatches.
	# The extra pair of parentheses around the first namepattern will be submatch 1.
	# The extra pair of parentheses around the "rest" will be submatch
	# 1 + number of parentheses paris in name pattern + 1.
	#
	print "### " 2 + count_parentheses(namepattern); 
	nodesetexpr = "(" namepattern ")((," namepattern ")*)";
	printf("%s: /^%s$/\n", "nodesetexpr", nodesetexpr);
	if ((pos = check_parentheses(namepattern)) > 0) {
		printf("Unbalanced parentheses detected, position %d\n!", pos);
	}
}




{
	if ((pos = check_parentheses($1)) != 0) {
		printf("Unbalanced parentheses: %d\n", pos);
	}
	else {
		print "###";
		show_submatches($1, nodesetexpr);
	}
}
