# Nodeset expression language specification

## Language alphabet
Formal languages are defined over a finite set of primitive tokens - literals -
that constitute the "alphabet" of the language. The language of nodename
expressions, defined here, is for concisely denoting a sets of nodenames.
Therefore, its alphabet must contain all characters that are valid nodename
characters. In addition, it must contain some additional literal characters
that are used as meta-characters of the language that are used to denote a
a particular operation or demarcate a particular language construct.

Existing nodeset expression expanding tools - Slurm's ```scontrol command```
[^SCONTROL] and the clustershell nodeset utility [^NODESET] - document the
syntax of operators and other meta-characters, but they are surprisingly silent,
up to the point of being rather sloppy, when it comes to valid characters
for nodenames.

After some experimenting its seems that likely that the approach has been:
- meta-characters cannot be escaped, therefore meta-characters cannot possibly
  occur as literal primitives in nodenames;
- every possible character that is not a meta-character is acceptable as nodename
  character.
This can lead to suprising or confusing outcomes. It makes it easier to use the
utility wrongly. In the long run it also makes it more difficult to extend the
language without breaking nodesets that used to be supported.

## Considerations pertaining to supported nodenames

The language being defined understands nodenames to be DNS compatible names,
or to be derived from such names. That is: nodenames optionally, but not
necessarily are fully qualified domain names (FQDNs), but nodenames can be,
and more often are only the "first label" of an FQDN, or what is sometimes
called the "short hostname".

Though not the exclusive one, the most important use case for a fast nodeset
expand utility is the processing of downtime adminstration and accounting
related datasets that contain nodeset expressions that are produced by
Slurm commands such as sinfo [SINFO] and sacct [SACCT]. Therefore it is
important to take into account what the Slurm documentation describes as
restrictions or at least recommends with respect to nodenames.

Unfortunaltely, the Slurm documentation pertaining to the naming of nodes
contains the following statements that taken together reflect a somewhat
inconsistent design decision. On the one hand, nodenames are NOT treated as as
case insensitive strings. On the other hand, DNS hostnames, or entries in the
```/etc/hosts``` file, are explicitly mentioned as the source of nodenames.

From the Slurm configuration file manual page [^SLURMCONF]:
>
> The contents of the (slurm configuration) file are case insensitive except
> for the names of nodes and partitions.
>
> ( ... )
>
> NodeName
>       Name that Slurm uses to refer to a node. Typically this would be the
>       string that "/bin/hostname -s" returns. It may also be the fully
>       qualified domain name as returned by "/bin/hostname -f" (e.g.
>       "foo1.bar.com"), or any valid domain name associated with the host
>       through the host database (/etc/hosts) or DNS, depending on the
>       resolver settings. Note that if the short form of the hostname is
>       not used, it may prevent use of hostlist expressions (the numeric
>       portion in brackets must be at the end of the string).
>

The uneasiness comes from the fact that, while the convention is to represent
them using lowercase letters only, DNS protocols are required to treat
hostnames as case insensitive [^RFC1034], [^RFC4343].

The choice made here is to follow DNS in the following way: the alphabet of
the language does not contain any uppercase letters. A string supposed to
contain a nodeset expression is _forced to lowercase, before it is parsed_.
This has the effect of making the addition of strings like "NODE1", "node1",
"Node1", "noDe1", etc., idempotent.

Sites may however have reasons to their Slurm nodes using name schemes in
which character casing _does_ matter for denoting distinct nodes.  If the case
insensitivity as described is _not_ desired, it is fairly easy to change in an
implementation that uses regular expression constants, by extending
```[a-z0-9_-]``` to ```[A-Za-z]0-9]_-```.

To summarize: the language of nodeset expressions specified here, recognizes the
following as valid nodename characters:

- The 26 letters of the roman alphabet in lowercase
- The 10 decimal digits
- The hyphen ("-")
- The underscore ("_")
- The period (".") - but only to connect the different labels of a fully
  qualified domain name.

### Nodemames (_not_ nodeset xpressions) grammar
As regular expressions tend to get long and hard to read it may be helpful to
present them in sub-expressions for smaller parts as annotation to a grammar
in BNF form.

[^SCONTROL]: SchedMD, Slurm workload manager, version 23.02 manual page,
"scontrol - view or modify Slurm configuration and state",
https://slurm.schedmd.com/scontrol.html (last visited: 20231012)

[^NODESET]: Clustershell version 19.02 NodeSet Module documentation,
https://clustershell.readthedocs.io/en/latest/api/NodeSet.html
(last visited: 20231012)

[^SLURMCONF]: SchedMD, Slurm workload manager, version 23.02 manual page,
"slurm.conf - Slurm configuration file",
https://slurm.schedmd.com/slurm.conf.html (last visited: 20231014)

[^RFC1034]: Mockapetris, P., "Domain Names - Concepts and Facilities", STD 13,
RFC 1034, November 1987.
https://www.rfc-editor.org/rfc/rfc1034.txt (last visited: 20231014)

[^RFC4343]: Eastlake, D. "Domain Name System (DNS) Case Insensitivity
Clarification", RFC 4343, January 2006.
https://www.rfc-editor.org/rfc/rfc4343.txt (last visited: 202310140

