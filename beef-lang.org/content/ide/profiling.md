+++
title = "Profiling"
+++

## Profiling overview

The Beef IDE profiler is a sampling profiler, which takes callstack samples of the target application many times per second and generates an overal performance report after the profiling session has ended. The accuracy of the report is increased by profiling over a longer period of time or by increasing the sample rate. 

Profiling can be initiated at any point during the execution of the target program, and can even be initiated by request of the target program via the "System.Diagnostics.Profiler" class. This can be useful for profiling over a program-defined time period such as while performing a specific long calculation.