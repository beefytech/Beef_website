+++
# Hero widget.
widget = "hero"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 10  # Order that this section will appear.

#title = "Beef"

# Hero image (optional). Enter filename of an image in the `static/img/` folder.
hero_media = "Beef256.png"

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
  url = "setup/BeefSetup_0_42_0.exe"
  label = "Beef for Windows"
  icon_pack = "fas"
  icon = "download"
  
[cta_alt]
  url = "/docs"
  label = "View Documentation"

# Note. An optional note to show underneath the links.
[cta_note]
  label = '<a href="docs/getting-start/building/">Build from source</a>'
+++

Beef is an open source performance-oriented compiled programming language which has been built hand-in-hand with its IDE environment.

Binaries are available for Windows, and Linux is supported via building from source.
