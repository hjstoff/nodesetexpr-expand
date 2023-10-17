# Nodeset expression language specification

Formal anguages are defined over a finite set of primitive tokens - literals -
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

[^SCONTROL]: SchedMD, Slurm workload manager, version 23.02 manual page,
"scontrol - view or modify Slurm configuration and state"
https://slurm.schedmd.com/scontrol.html (last visited: 20231012)

[^NODESET]: Clustershell version 19.02 NodeSet Module documentation,
https://clustershell.readthedocs.io/en/latest/api/NodeSet.html
(last visited: 20231012)


