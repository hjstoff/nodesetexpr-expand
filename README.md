# nodesetexpr-expand
Nodeset expressions are a concise way to denote a potentially large set of node\
names that are systematically named using some numeric scheme. Nodeset
expression expanding pertains to the parsing of such expressions, to produce
the complete set of node names denoted by the expression.

Nodeset expressions occur in line records output by commands of the Slurm
[^SLURM] workload manager system, like ```sinfo``` [^SINFO] or ```sacct```
[^SACCT], to indicate which nodes are in a particular state, members of a
particular partition, or to indicate on which set of nodes a  job ran.

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

## Existing utilities for handling nodeset expressions
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
The clustershell nodest utility is the more versatile command of the two. It has more
capabilities with respect to nodeset handling then I need, but I have used its nodeset
expanding capability quite a lot over the years. 
 





   
12345678901234567890123456789012345678901234567890123456789012345678901234567890


[^SLURM]: SchedMD, Slurm workload manager documentation,
https://slurm.schedmd.com/documentation.html (last visited: 20231014).

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


