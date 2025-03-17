+++
title = "Package Manager"
weight = 60
+++

## Package manager overview

The Beef build tools includes a package manager which can retrieve remote library dependencies. In the IDE, right-clicking on 'Workspace' and selecting 'Add Remote Project...' will show a dialog where a remote URL and Cargo-style SemVer version constraints can be entered. Project properties now include 'Remote URL' and 'Ver Constraint' sections in the 'Dependencies' panel, which allows libraries to specify their version constraints. In the case that your workspace contains multiple conflicting version constraints for the same library, the package manager will choose the highest version available that satisfies the most number of constraints.

When remote libraries are used in a project, a `BeefSpace_Lock.toml` file will be generated which will "lock" your workspace to the best version match currently on the remote. In the IDE, right-clicking on 'Workspace' and selecting 'Update Version Locks' can be used to update all the version locks in the workspace.

If the remote project contains a directory named 'Setup', the package manager will build and run the workspace in that directory. This program can perform any action needed to set up the library, including downloading or building additional binary library dependencies.

### Version constraints
```s
1.2.3  :=  >=1.2.3, <2.0.0
1.2    :=  >=1.2.0, <2.0.0
1      :=  >=1.0.0, <2.0.0
0.2.3  :=  >=0.2.3, <0.3.0
0.2    :=  >=0.2.0, <0.3.0
0.0.3  :=  >=0.0.3, <0.0.4
0.0    :=  >=0.0.0, <0.1.0
0      :=  >=0.0.0, <1.0.0

~1.2.3  := >=1.2.3, <1.3.0
~1.2    := >=1.2.0, <1.3.0
~1      := >=1.0.0, <2.0.0

*     := >=0.0.0
1.*   := >=1.0.0, <2.0.0
1.2.* := >=1.2.0, <1.3.0

>= 1.2.0
> 1
< 2
= 1.2.3
```