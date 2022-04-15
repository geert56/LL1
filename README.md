# LL(1) Checker

## Background

This language tool is a resurrection of code developed at Eindhoven University
in 1993 or thereabouts. Its roots go back even further e.g. a program to
generate railroad diagrams for grammars was developed in the late 1980s.

The original program was written in Pascal and ran on Apollo Domain
workstations and later Hewlett-Packard HP9000 minicomputers.
The resurrection merely consisted of porting the dialect of Pascal to Free
Pascal. This way it now compiles and runs on many modern architectures.

## Introduction

An LL(1) checker is a formal language tool that checks whether a given grammar
complies with the LL(1) condition. This means that the grammar must not be
left-recursive and that in all cases at most 1 token look-ahead suffices to
decide which production rule applies for a particular non-terminal occurrence
on the right-hand side of a rule. (The program actually checks for the
so-called **strong** LL(1) condition, which stipulates that any input seen so
far is irrelevant to the decision).

The grammar is specified in a very flexible Domain Specific Language (DSL)
dubbed SBNF which stands for Super Backus-Naur Form. John Backus and Peter
Naur were the authors of the report on Algol 60 where the use of a formal
notation for syntax description was first introduced.

##
## References

> <a id="1">[1]</a>
"Syntax of Programming Languages: Theory and Practice,"
R. Backhouse, Prentice-Hall International, 1979
