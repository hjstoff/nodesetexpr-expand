# nodesetexpr-expand
Nodeset expressions are a concise way to denote a potentially large set
of node names that are systematically named using some numeric scheme.
Nodeset expression expanding pertains to the parsing of such expressions,
to produce the complete set of node names denoted by the expression.

Nodeset expressions occur in line records output by commands of the
Slurm [^SLURM] workload manager system, like ```sinfo``` [^SINFO] or
```sacct``` [^SACCT], to indicate which nodes are in a particular state,
members of a particular partition, or to indicate on which set of nodes a 
job ran.

Nodenames are strings. To clarify what is meant by systematically naming
nodes using some numeric scheme, here are some simple but quite representative
examples. A cluster may have several thin compute nodes and several fat compute
nodes. The first group is systematically named with a prefix "tcn" and a number,
the latter group is systematically named "fcn" and a number.
- The nodeset expression "tcn[1-4,12,27,30-33]" would denote nodenames "tcn1",
  "tcn2", "tcn3", "tcn4", "tcn12", "tcn27", "tcn30", "tcn31".
- The nodeset expression "fcn[1-2,35],tcn[2,6,8]" would denote nodenames "fcn1",
  "fcn2","fcn35", "tcn2", "tcn6" and "tcn8".
  
Some sites, apply such a scheme but like to standardize the nodename length for
sorting or other purposes. Nodeset expressions can express such names as well:
- The nodesert expression "tcn[0001-0004,tcn0999]" would denote nodenames
  "tcn0001", "tcn-0002", "tcn0003", "tcn0004", and "tcn0999".
  
  


[^SLURM]: SchedMD, Slurm workload manager documentation,
https://slurm.schedmd.com/documentation.html (last visited: 20231014).

[^SINFO]: SchedMD, Surm workload manager, version 23.02,
"sinfo - View information about Slurm nodes and partitions", manual page,
https://slurm.schedmd.com/sinfo.html (last visited: 202311012)

[^SACCT]:
