#! /usr/bin/gawk -bf

#
# On syntax of hostnames:
# Linux hostname(7) manual page,
# https://man7.org/linux/man-pages/man7/hostname.7.html (last visited: 20231014)
#
# > Each element of the hostname must be from 1 to 63 characters long and the
# > entire hostname, including the dots, can be at most 253 characters long.
# > Valid characters for hostnames are ASCII(7) letters from a to z, the digits
# > from 0 to 9, and the hyphen (-). A hostname may not start with a hyphen.
#

function is_shorthostname(s) {
#
# Return 1 (true) if s grammatically is a valid unqualified - "short" - hostname.
# Return 0 (falsei) if it is not.
#
	return s ~ /^[A-Za-z0-9][A-Za-z0-9-]{0,62}$/;
}

function is_hostname(s) {
#
# Return 1 (true) if s grammatically is a valid hostname, either unqualified
# or qualified with a domain name suffix (there is no way to tell if the suffix
# is _fully_ qualifying, as the number of labels used differs from domain to
# domain).
# Return 0 (false) if it is not.
# Note that the overall length limit of valid nodenames cannot feasibly be
# expressed by means of a regular expression, because the number of lables as
# well as the length of each label may vary.
#
	if (s ~ /^[A-Za-z0-9][A-Za-z0-9-]{0,62}([.][A-Za-z0-9][A-Za-z0-9-]{0,62})*$/) {
		return length(s) <= 253;
	}
	return 0;
}

function is_qualifiedhostname(s) {
# Return 1 (true) if s grammatically is a hostname that is qualified with a
# domain suffix of one or more labels (there is no way to tell if the suffix is
# _fully_ qualifying, as the number of labels used differs from domain to
# domain).
# Return 0 (false) if it is not.
#
	if (s ~ /^[A-Za-z0-9][A-Za-z0-9-]{0,62}([.][A-Za-z0-9][A-Za-z0-9-]{0,62})+$/) {
		return length(s) <= 253;
	}
	return 0;
}


BEGIN {
	printf("Enter value to be tested for compliancy with requirements for hostnames ... > "); 
}

NF >= 1 {
	printf("\nTesting '%s', %d characters:\n", $1, length($1));
	printf("Q: Is it a hostname compliant string (whether 'short' or with a suffix')? A: %3s\n", 
			is_hostname($1) ? "Yes": "No");
	printf("Q: Is it a short hostname compliant string?                               A: %3s\n", 
			is_shorthostname($1) ? "Yes": "No");
	printf("Q: Is it a qualified hostname compliant string?                           A: %3s\n\n", 
			is_qualifiedhostname($1) ? "Yes": "No");

	printf("Enter value to be tested for compliancy with requirements for hostnames ... > "); 
}
