+++
# Hero widget.
widget = "hero"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 10  # Order that this section will appear.

#title = "Beef"

# Hero image (optional). Enter filename of an image in the `static/img/` folder.
hero_media = "Beef384.png"

[design.background]
  # Apply a background color, gradient, or image.
  #   Uncomment (by removing `#`) an option to apply it.
  #   Choose a light or dark text color by setting `text_color_light`.
  #   Any HTML color name or Hex value is valid.

  # Background color.
  # color = "navy"
  
  # Background gradient.
  gradient_start = "#4bb4e3"
  gradient_end = "#2b94c3"
  
  # Background image.
  # image = ""  # Name of image in `static/img/`.
  # image_darken = 0.6  # Darken the image? Range 0-1 where 0 is transparent and 1 is opaque.

  # Text color (true=light or false=dark).
  text_color_light = true

# Call to action links (optional).
#   Display link(s) by specifying a URL and label below. Icon is optional for `[cta]`.
#   Remove a link/note by deleting a cta/note block.
[cta]
  url = "setup/BeefSetup_0_43_2.exe"
  label = "Beef for Windows"
  icon_pack = "fas"
  icon = "download"
  
[cta_alt]
  url = "/docs"
  label = "View Documentation"

# Note. An optional note to show underneath the links.
[cta_note]
  label = '<a href="docs/getting-start/building/">Build from source</a><br><a href="https://github.com/beefytech/Beef_website/tree/master/Samples/SpaceGame">View example source code</a><br><a href="spacegame">Play Space Game wasm example</a>'
+++

Beef is a high-performance multi-paradigm open source programming language with a focus on developer productivity.

### Tier 1 Platforms (IDE + Binaries)
Windows 64 bit & 32 bit

### Tier 2 Platforms (Build from source)
Linux, macOS, Wasm

### Tier 3 Platforms (Experimental)
Android, Nintendo Switch, PS5, Xbox Series X
