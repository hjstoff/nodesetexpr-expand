# nodesetexpr-expand

## What this project is about
Nodeset expressions are character strings that constitute a (potentially)
concise way to denote a potentially large but finite _set_ of nodenames.
Nodenames in this context are names of computer systems, such as the nodes of
a cluster of compute nodes for high performance computing and/or capacity
computing. The potential conciseness of the expressions requires that the nodes
involved have been named systematically following some numbering scheme -
something simple (but quite realistic) like: "_node1_", "_node2_", ...,
or: "_xtype_node001_", "_xtype_node002_", ..., "_ytype_node001_", "_ytype_node002_", ...

This project focusses on:
- accurately describing (a) language(s) for nodeset expressions;
- developing and maintaining tooling for producing from nodeset expressions,
  the explicit enumeration of all set members denoted by such expressions.

More specifically, nodeset expression _expanding_ pertains to the parsing of nodeset
expressions, and to the subsequent production of each of the nodenames denoted by
such expressions, as sets of individual character strings - viz. a unique distinct
one for each set member - to be stored in some appropriate "container type" that,
at least during production, guarantees the uniqueness of each of its elements.

## Scope limitations and use case derived design guidance
The inverse operation of nodeset expression expanding is _compressing_, or
_folding_ a list of nodenames into a nodeset expression. Such inverse operations
are _not_ in scope of this project. In particular, whether optimised compressing,
finding the most succint nodeset expression, would be easier or more difficult
to implement, is not having any bearing on the outcome of decisions in this
project pertaining to the nodeset expression language's syntax or its semantics.

Nodeset expressions, and tools that produce them, already exist for quite some time.
Though not the only use case, by far the _most important_ use case, from my perspective,
for any tooling delivered by this project, is the handling of nodeset expressions that
are produced by the utilties of the Slurm workload manager system [^SLURM].

Design considerations in this project are guided or restricted by the requirement that
the nodeset expressions produced by Slurm tools must be recognized as valid language in
terms of the language(s) and tooling described here, **_on the prerequisite that the Slurm
instance has all of its nodenames configured in a way that is compliant with the
requirements for hostnames of the Domain Name System (DNS) [^DNS], or the first
label [^DNSLABEL] of such names_**.

Apart from being recognized as valid, the language(s) and tooling of this project must
also _attribute the same meaning to the nodeset expressions output by Slurm tools_ - that
is: they must expand to an enumeration of literal nodenames that is equivalent to the
enumeration of nodenames intended to be denoted by the Slurm tooling that created the
nodeset expression.

## Defining ingredients of a nodeset expression language: alphabet and grammar

### Nodeset expression language grammar
A nodeset expression _language_ is simply the language in which nodeset expressions
are formulated.

But a nodeset expression language is a _formal_ language. It has:
- a well-defined alphabet, i.e: a finite set of literal characters that can be used by
  expressions that belong to the language
- a well-defined syntax, or grammar, i.e: a set of rules that defines how sequences of
  characters that are part of the alphabet can be combined to form valid language
  constructs.

The above implies that character strings, that contain a character that does not belong
to the alphabet of a nodeset expression language _L_, by definition are _not_ part of
the language, and hence are not nodeset expressions at all.

It also implies that a sequence of alphabetical characters of _L_, that cannot possibly
be produced by following the syntax rules of _L_, are not part of the language, and hence
are not nodeset expressions at all.

#### Relation to the grammar of nodename language  
The nodeset expresion language cannot be but closely related to the language of nodenames.
If, as indicated above, the DNS requirements for valid hostnames are to be taken as a norm
for valid nodenames, the language of nodenames is best characterized as a regular language.
However, some of the DNS requirements for hostnames cannot be tested by means of a regular
grammar and tested by regular expression based tests alone:

- A grammar may specify that both sequences of uppercase and lowercase characters of the
  alphabet are valid, but by itself it cannot specify that 'A' is to be treated as
  the equivalent of 'a', 'B' as the equivalent of 'b', and so on. This is a semantic
  requirement.
- While the specification of length limits in terms of literal characterscan feasibly be
  specified by regular (sub-)expressions that deal with the repetition of character
  literals only, it is not feasible to do so, with - in a regular expression
  parenthesised - repetitions of such (sub-)strings. The DNS norm that a single "label" of
  a nodename must be limited to a maximum of 63 characters is doable to specify by means
  of a regular expression only. For the DNS norm, that the overall length limit for a
  fully qualified domain name (FQDN) is 253 characters, this is not the case, because both
  the number of labels and the length of each label can vary.

See ```hostname-regex.gawk```, this project's repository, for validation functions using
a combination of regular expressions with simple length checks where regular expressions
alone are not feasible.

**N.B.:**   
The fact that the related language of nodenames is in essence a regular language does not
imply that the language of nodeset expressions is necessarily a regular language as well.
This depends mainly on the number of operators to be implemented and, if there is more than
one operator, whether or not the means to specify the scope of operators by grouping
(e.g. using parentheses) is useful for such a language.
        
### Nodeset expression language semantics
If the nodeset expression language is to have any practical purpose, it has to be
meaningful is some sense: most, and preferably all, of the language constructs that
can be produced by appying its rules, also have a well-defined meaning. Unfortunately,
that what is denoted by the expressions of a language, the semantics of its constructs,
is something that it is much more difficult to be precise or non-ambiguous about than its
syntax, even for formal languages. 

Since a nodeset expression languages is for denoting sets of nodenames, its alphabet
and grammar, must be closely related to the language for expressing nodenames, but it
is definitely not the same language. Besides valid node name characters, the alphabet
of a nodeset epxression language must contain at least some additional characters that
denote some operation for construction of a set of nodenames. Below, such characters
will sometimes be referred to as "meta-characters" to explicitly distinguish them from
nodename literals.

#### (One) meaning of the comma in nodeset expressions
One form - perhaps the most basic and explicit form - of a nodeset expression, that
a nodeset expression language must support, is a sequence of one or more literal
nodenames, where the individual nodenames are separated from each other by a token
that cannot be part of any nodename, a meta-character. Since we require compatibility
with Slurm's nodeset expression, that meta-character is the comma (",").

Nodeset expressions must denote _sets_. For the semantics of the this basic form, we
allow that multiple occurrences of the same name in the sequence perfectly valid, but
that they are _idempotent_. The semantics, that the expression denotes a set while
at the same multiple instances of the same string are tolerated in this basic list form,
require that the occurence of such redundant instances makes no difference for the
outcome of the expansion operation.

If we say that the comma is a set union operator, we can also reason about this
as follows:
- The union of any set with itself just renders the same set.
- So, if "node1" is a nodeset expression denoting a set with a single nodename, then a
  nodeset expression applying the union operation multiple times - like so:
  "node1,node1,node1,node1", or like so: "node1,node1" - should be accepted as valid
  nodeset expression.
- both examples result in the same thing, viz. a set, that when expanded just produces
  the same single nodename.

Note that, if the language of nodenames is to follow DNS rules, which require case
insensitive treatment of names, then also a nodeset expression like the following should
expand to just a single name: "node1,NODE1,noDE1,Node1,nODE1,NoDe1". 

#### More operations and meta-characters to denote them
While to be treated as valid, the union of a whole series of literal nodenames obviously
is not the most concise form of nodeset expressions. Nodeset expressions get their
conciseness, and thereby their usefulness, from also using language constructs that
presuppose that the nodenames to be denoted were created by systematically applying some
numbering scheme. The most obvious language construct that results in conciseness,
is one that enables the expression of numeric ranges, that in naming nodes, by merely
naming their bounds.

( ... ) 

Nodeset expressions occur in line records output by commands of the Slurm
[^SLURM] workload manager system, like ```sinfo``` [^SINFO] or ```sacct```
[^SACCT], to indicate which nodes are in a particular state, members of a
particular partition, or to indicate on which set of nodes a job ran.

## Some examples of nodeset expressions
Nodenames are strings. To clarify what is meant by systematically naming
nodes using some numeric scheme, here are some simple, but quite representative,
examples. A cluster may have several thin compute nodes and several fat compute
nodes. The first group is systematically named with a prefix "tcn" and a
number, the latter group is systematically named "fcn" and a number.
- The nodeset expression "tcn[1-4,12,27,30-33]" would denote nodenames "tcn1",
  "tcn2", "tcn3", "tcn4", "tcn12", "tcn27", "tcn30", "tcn31".
- The nodeset expression "fcn[1-2,35],tcn[2,6,8]" would denote nodenames
  "fcn1", "fcn2","fcn35", "tcn2", "tcn6" and "tcn8".
  
Some sites apply similar naming schemes but like to standardize the nodename
length, using padding with zeros, for sorting or other purposes. Nodeset
expressions can express such names as well:
- The nodeset expression "tcn[0001-0004,tcn0999]" would denote nodenames
  "tcn0001", "tcn-0002", "tcn0003", "tcn0004", and "tcn0999".

A multi-dimensional names scheme, in which the node names reflect the room
and rack in which the nodea are located, can also be expressed succintly with
nodename expressions: 
- A nodeset expression like "room[1-3]-rack[1-10]-node[1-18]" denotes a set
  of 3 x 10 x 18  = 540 distinct nodenames

## Existing utilities handling nodeset expressions and the rationale for creating another one
There are at least two existing utilities for handling nodeset expressions that
include the ability to expand such expressions in their handling repertoire:

1. **Slurm's ```scontrol show hostlist``` command [^SCONTROL]**
2. **The clustershell ```nodeset --expand``` command [^NODESET]**

The behaviour of these commands, their restrictions and capabilities,are not
exactly the same, but their functionality is overlapping.

The first one is obviously only around on systems where Slurm is installed,
which is a disadvantage when Slurm data on job accounting, on downtime
statistics, etc. are processed are taken somwhere else to create reports.
It also has the - documented - drawbacks.
1. It does not have in a set-like way in that it does not deduplicate items.
```
$ scontrol show hostnames xx[1-4,3]
xx1
xx2
xx3
xx4
xx3
$ 
```
2. It cannot expand a nodeset expression if that expression does not end in
an expandable part:
```
$ scontrol show hostnames r[1-2]n[1-2]
r1n1
r1n2
r2n1
r2n2
$ scontrol show hostnames r[1-2]n[1-2]-bmc
Invalid hostlist: r[1-2]n[1-2]-bmc
$
```
The clustershell nodest utility is the more versatile command of the two. It has
more capabilities with respect to nodeset handling then I will ever need, but I
have productively used its nodeset expanding capability quite a lot over the years. 
Using it as utility on a massive scale, in scripts analyzing and reporting on
datasets that contained lots of nodeset expressions to expanded, it became
irritatingly obvious that the programs runtime performance left very much to
be desired. With large datasets, I found that _at least_ 90% of the runtime spent
was due to using the ```nodeset``` utility for nodeset expression expansion!

Part of its slowness comes from the fact that using it as a standalone utility
in a script that is not implemented in ```python3``` implies a ```fork(2)```
[^FORK] and ```execve(2)``` [^EXECVE] system call for every invocation. Further
contributing to its slowness is that what is loaded by the ```execve(2)```
a python interpreter,which then subsequently loads a bunch of python modules
before it eventually starts doing the work that it was called for.

Writing a preliminary version of my own nodeset expression expander, implemented
as a function in ```gawk(1)``` [^GAWK], that verifiably gave me the exact same
outcomes on my datasets as the scripts using the clustershell nodeset utility made
me decide that I should take this a bit further and develop this implementation
into a bit more generic and well-documented utility. Depending on the datasets - most
likely on the number and size of nodeset expressions they contained - the typical
runtime of 12 to 15 minutes was reduced to 2.5 to 3.5 seconds!

The approach taken is a bit of a formal one:
- First, design the nodeset expression language as a formal language with
  restricted alphabet and a grammar,
- Second, annotate the grammar with clear semantics - make the utility
  "hard to use wrongly".

My most important use case for a fast nodeset expand utility is the processing of
downtime administration and accounting related datasets that contain nodeset
expressions that are produced by Slurm commands. The syntax of that language is
therefore very heavily influenced by how those expressions look - afterall, it must
be compatible with them and interpret them in the way intended by the Slurm commands
that output them - expand them to the same set of nodenames.

Likewise, some extended features have been taken over from expressions that are
understood by the clustershell ```nodeset --expand``` command, but then again some
have not, for reasons pointed out in the language specification document.


[^SLURM]: SchedMD, Slurm workload manager documentation,
https://slurm.schedmd.com/documentation.html (last visited: 20231014).

[^SLURMCONF]: SchedMD, Slurm workload manager documentation, version 22.02
manual page, "slurm.conf - Slurm configuration file"
https://slurm.schedmd.com/slurm.conf.html (last visited: 20231014).

[^DNS]: There are several relevant so-called "Request for Comment" documents
(RFCs). The oldest one is probably RFC 952 [^RFC952]. Other relevant RFCs are
RFC 1034 [^RFC1034], RFC 1123 [^RFC1123], and RFC 4343 [^RFC4343]. Some of
these documents may appear to be "ancient", but in fact they show that there
indeed some changes over time, but very limited ones, not so much with respect
to the characters that can be used in a hostname, but more to restriction on
which characters can be the first character of a hostname.

[^DNSLABEL]: Fully qualified domain names (FQDNs0 consist of several labels connected
by periods ("."). What is sometimes refered to as a "short hostname" is perfectly
acceptable as a nodename. A short hostname is the first label of an FQDN only, and
according to the SLURM documentation preferred over an FQDN as a nodename in defined
in the central Slurm configuration file [^SLURMCONF].

[^RFC952]: Harrenstein, K. et al., "DOD INTERNET HOST TABLE SPECIFICATION",
RFC 952, October 1985.
https://www.rfc-editor.org/rfc/rfc952.txt (last visited: 20231014)

[^RFC1034]: Mockapetris, P., "Domain Names - Concepts and Facilities", STD 13,
RFC 1034, November 1987.
https://www.rfc-editor.org/rfc/rfc1034.txt (last visited: 20231014)

[^RFC1123]: Braden, R., "Requirements for Internet Hosts -- Application and Support",
RFC 1123, October 1989.
https://www.rfc-editor.org/rfc/rfc1123.txt (last visited: 20231014)

[^RFC4343]: Eastlake, D., "Domain Name System (DNS) Case Insensitivity
Clarification", RFC 4343, January 2006.
https://www.rfc-editor.org/rfc/rfc4343.txt (last visited: 202310140

[^SINFO]: SchedMD, Slurm workload manager, version 23.02 manual page,
"sinfo - view information about Slurm nodes and partitions",
https://slurm.schedmd.com/sinfo.html (last visited: 202311012)

[^SACCT]: SchedMD, Slurm workload manager, version 23.02 manual page,
"sacct - displays accounting data for all jobs and job steps in the
Slurm job accounting log or Slurm database",
https://slurm.schedmd.com/sacct.html (last visited: 20231012)

[^SCONTROL]: SchedMD, Slurm workload manager, version 23.02 manual page,
"scontrol - view or modify Slurm configuration and state"
https://slurm.schedmd.com/scontrol.html (last visited: 20231012)

[^NODESET]: Clustershell version 19.02 NodeSet Module documentation,
https://clustershell.readthedocs.io/en/latest/api/NodeSet.html
(last visited: 20231012)

[^FORK]: Linux System Calls manual, "fork - create a child process",
https://man7.org/linux/man-pages/man2/fork.2.html
(last visited: 20231012)

[^EXECVE]: Linux System Calls manual, "execve - execute program",
https://man7.org/linux/man-pages/man2/execve.2.html
(last visited: 20231012)

[^GAWK]: GNU/Linux Utility commands , "gawk - pattern scanning and
processing language", https://man7.org/linux/man-pages/man1/gawk.1.html
(last visited: 20231002)



