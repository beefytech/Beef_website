+++
title = "FAQ"
description = ""
weight = 100
+++

#### Is there is Visual Studio Code language server extension?
This is not planned as an official project, but a community made extension is available [here](https://github.com/MineGame159/Beef/tree/lsp/BeefLsp).  
Further help by community contributers, such as making the language server work in other programs would be appreciated.

#### Why is the IDE only available for Windows?
Beef's primary initial target is game development. The majority of game development is performed on Windows, and it's critical to concentrate on making that primary development experience as good as possible.

#### What would it take to make the IDE work on Linux or macOS?
It's often assumed that the reliance upon DirectX for GUI rendering is the primary issue, but this is only one small part of the work required. In fact, a partial OpenGL rendering backend already exists in BeefySysLib/platform/sdl. There are many other GUI-related issues to work through, such as handling platform-specific Open/Save/Select Folder dialogs, system menus, multimonitor support, alternate hotkey standards, and many other system-undiscovered problems. The debugger is a much larger issue - the Windows IDE utilizes a custom Windows-only debugger engine which is an integral part of the hot code swapping support. Probably the best approach would be to wrap the LLDB engine and then attempt to extend it to support hot code swapping.

#### Why aren't there binaries available for Linux or macOS?
There will be, at some point.

#### Is Beef available for consoles?
Work has not yet started on this, but it is a priority item.

#### How long has BeefLang been in development?
Work on the language and the IDE started in September 2014, and the first public release was in January 2020.

#### Is Beef suitable for production code right now?
Beef is a new language, which has it's advantages and disadvantages - early adopters can help shape the direction of the language, and will often receive personal attention for their issues. New languages are subject to breaking changes at times, however, and may contain more bugs than older languages. Beef bugs are usually fixed quickly.

#### How can I contribute?
The best way to help is to to simply use Beef, even for small projects, and report any bugs or suggestions as GitHub issues, and tell others about your experience. Working on the core library is another good area, since it is a little sparse in many obvious areas.

#### Can I help support Beef financially through Patreon or something?
This project is not in need of financial support.

#### Who are you?
BeefLang was started by Brian Fiete, co-founder of PopCap Games and PopCap employee through 2011. Brian has been working more or less full-time on BeefLang since September 2014.

#### I don't like the name or logo of the language. Will you change it please?
The logo will likely change, but the name will not change.

#### Are there any plans for async/await or coroutines?
These will be considered for a future version of BeefLang.

#### How do I get the name of the current executable?
`System.Environment.GetExecutableFilePath`
