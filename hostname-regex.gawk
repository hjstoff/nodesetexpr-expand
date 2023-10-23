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
	return s ~ /^[A-Za-z0-9][A-Za-z0-9-]{0,62}$/;
}

function is_hostname(s) {
	if (s ~ /^[A-Za-z0-9][A-Za-z0-9-]{0,62}([.][A-Za-z0-9][A-Za-z0-9-]{0,62})*$/) {
		return length(s) <= 253;
	}
	return 0;
}

NF >= 1 {
	printf("%d, %s\n", length($1), is_hostname($1) ? "yes" : "no");
}
