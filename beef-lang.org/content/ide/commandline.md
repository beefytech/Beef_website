+++
title = "Command-line arguments"
+++

## Beef IDE command-line arguments

The Beef IDE is a GUI application that does not require any arguments, but it does accept some arguments.

|Argument    |Description      |
|----|------|
|-config=&lt;config>|Sets the config|
|-launch|Compile and run workspace startup project in debugger. Everything after '--' will be passed as arguments.|
|-launch=&lt;path>|Compile and run executable 'path' in debugger. Everything after '--' will be passed as arguments.|
|-launchDir=&lt;path>|Sets the launch working directory|
|-launchPaused|With '-launch', starts the debugger paused|
|-new|Creates a new workspace and project|
|-path&lt;Path>|Sets target file (action depends on filetype)|
|-platform=&lt;platform>|Sets the platform|
|-test=&lt;path>|Executes test script|
|-verbosity=&lt;verbosity>|Set verbosity level to: quiet/minimal/normal/detailed/diagnostics|
|-workspace=&lt;path>|Sets workspace path|
