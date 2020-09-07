+++
title = "Themes"
+++

## Themes

The IDE supports theme files, which allows for customizing the look of the IDE. Theme files should be placed in a directory within the `bin/themes` directory. Users can set their theme in the `File\Preferences\Settings`, under `UI\Theme`. The specified value can either be a directory name relative to the `themes` direcetory, or a theme `.toml` file relative to the `theme` directory.

Replacing images requires providing PSD files containing image segments that will override the standard `bin/images/DarkUI.png`, `bin/images/DarkUI_2.png`, and `bin/images/DarkUI_4.png` files. The theme files should be named `UI.psd`, `UI_2.psd`, and `UI_4.psd`, respectively. The file trios represent different levels of scale. 

Not all image files must be present, and not all image segments must be filled in on each file. The 'holes' will be filled in with resized image segments either from other theme image files, or from the default image segments. It is possibly, for example, to provide only a single `UI_4.psd` file with only the checkbox image segment replaced. It's generally important to provide `UI.png` images for 1x scale, however, for image segments that require clean edges, as image rescaling can produce non-aligned/blurry results.

When the user selects your theme in the IDE, the `bin/images/ImgCreate.exe` will be executed, which will generate `UI.png`, `UI_2.png`, and `UI_4.png` by scaling and merging the provided PSDs. These files should be considered cache files, and they will be rebuilt when any of their source files change, which allows updating both the theme and for forward compatibility with new image segments added in new IDE releases.

Themes also allow a `theme.toml` file for overriding colors.

```
[Colors]
Text = 0xFFFFFFFF
Window = 0xFF595962
Background = 0xFF26262A
SelectedOutline = 0xFFCFAE11
MenuFocused = 0xFFE5A910
MenuSelected = 0xFFCB9B80
Code = 0xFFFFFFFF
Keyword = 0xFFE1AE9A
Literal = 0xFFC8A0FF
Identifier = 0xFFFFFFFF
Comment = 0xFF75715E
Method = 0xFFA6E22A
Type = 0xFF66D9EF
RefType = 0xFF66D9EF
Interface = 0xFF66D9EF
Namespace = 0xFF7BEEB7
DisassemblyText = 0xFFB0B0B0
DisassemblyFileName = 0XFFFF0000
Error = 0xFFFF0000
BuildError = 0xFFFF8080
BuildWarning = 0xFFFFFF80
VisibleWhiteSpace = 0xFF9090C0
```

Users can provide a `user.toml` file in a specific theme directory, which will be processed after the `theme.toml` file to override one or more theme settings.