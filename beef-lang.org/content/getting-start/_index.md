+++
title = "Getting Started"
description = ""
weight = 2
alwaysopen = true
+++

## Welcome to Beef

Beef is primarily an IDE-based experience, but command-line building is also supported. Your first step is to [install Beef]({{< ref "getting-start/installation.md" >}}).

### Creating an IDE-based "Hello World"

* Run the Beef IDE
* Create a new project by selecting File/New/Project and create a new Console project named "Hello"
* Right click on the new project, select "New Class...", and enter "Program" as the name.
* Enter the following text in the newly-created file

```C#
using System;

namespace Hello
{
	class Program
	{
    	static void Main()
    	{
	        Console.WriteLine("Hello, world!");
    	}
	}
}
```
* Press F5 to compile and run

### Creating an command-line based "Hello World"

* Create a new directory named "Hello" somewhere
* "cd" into that directory
* Run "BeefBuild -new" to initialize a new workspace and project in that directory
* Create a "src/Program.bf" text file and paste in the contents from the box above
* Run "BeefBuild -run" to compile and execute