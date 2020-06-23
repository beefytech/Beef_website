+++
title = "Testing"
description = ""
weight = 90
+++

Every workspace contains a 'Test' configuration by default, which can be invoked either by passing '-test' to BeefBuild or via the 'Test' menu in the IDE. Tests are defined by using the `[Test]` attribute on any static method.

```C#
[Test]
public static void TestAPI()
{
	Test.Assert(API_Init());
	Test.Assert(API_GetVersion() == 12);
}
```

In the Workspace configuration, make sure 'Projects' has the 'Test' configuration specified for any projects that you want to run Tests on. By default,  the first project specified in the workspace will be configured for testing.

Beef tests are suitable for use in CI systems such as Jenkins, as BeefBuild will emit testing text with timing statistics, and will report success or failure via standard return codes.