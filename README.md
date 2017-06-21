# PDUI

A GUI framework designed to provide a greater degree of ease for creating interfaces within Payday 2

---

## Contents

1. [Implemented features](#implemented-features)
    1. [Planned features](#planned-features)
2. [Supported Elements](#supported-elements-and-their-attributes)
3. [Metadata system](#metadata-system)
    1. [Sample metadata](#sample-metadata)
4. [How to use](#how-to-use)
    1. [Defining an element in JSON](#defining-an-element-in-json)
    2. [Loading UI files into the workspace](#loading-ui-files-into-the-workspace)


## Implemented features
- ~~UI created at runtime from JSON file~~
- ~~Element animation support in JSON~~
    - ~~Label bounce-marquee~~
    - ~~Custom animations~~
- ~~Custom elements~~
- ~~JSON variables~~
- ~~Hierarchical positioning~~
- ~~Relative sizes~~

### Planned features
- Hierarchical invalidation
- Relative Positions
- UI hooks + Callbacks

## Supported elements, and their attributes
- Panel
    - bounds : [x, y, w, h]
    - children : []
    - animation : Animation object / "Animation variable"
- Bitmap
    - texture : "texture path"
    - wrap : "texture wrap"
    - colour/color : [r, g, b] / "Colour variable"
    - alpha : 0-100
    - blend : "Blend mode"
    - bounds : [x, y, w, h]
    - template : "Render template"
    - region : [x, y, w, h]
    - animation : Animation object / "Animation variable"
- Rect
    - bounds : [x, y, w, h]
    - colour/color : [r, g, b] / "Colour variable"
    - alpha : 0-100
    - animation : Animation object / "Animation variable"
- Text
    - bounds : [x, y, w, h]
    - font : "Font path" / "Font variable"
    - size : "Font size"
    - colour/color : [r, g, b] / "Colour variable"
    - alpha : 0-100
    - halign : "Horizontal align"
    - valign : "Vertical align"
    - text : "Label content"
    - animation : Animation object / "Animation variable"

## Metadata system

### Sample metadata

The following JSON defines 3 fonts, 5 colours, and 2 variables.
Variables can be used in place of any attribute other than within "children".
Here, the "textBounceBounds" variable is defining a 4-element array, compatible with "bounds" attributes.
The "textBounceAnimationSet" variable is defining an animation set, this variable can be used in place of the "animation"
attribute, allowing for multiple elements to use the same animation.

```
"meta": {
  "fonts": {
    "eroded": "fonts/font_eroded",
    "medium": "fonts/font_medium_mf",
    "large": "fonts/font_large_mf"
  },
  "colours": {
    "red":   [255, 0,   0],
    "green": [0,   255, 0],
    "blue":  [0,   0,   255],
    "white": [255, 255, 255],
    "silver": [192, 192, 192]
  },
  "variables": {
    "textBounceBounds": [150, 10, 150, 24],
    "textBounceAnimationSet": [
      {
        "type": "marquee-bounce",
        "speed": 90,
        "left": 100,
        "right": 450
      }
    ]
  }
}
```

## How to use

[Example](example/)

### Defining an element in JSON

The `type` attribute is required, and is used to select the element type.

All other attributes are optional

If the `name` attribute is present, the named element can be requested in a lua function for a lower level of functionality

```
{
  "type" : <typename>       [Required]
  "name" : <element name>,
  <Other attributes>
}
```

### Loading UI files into the workspace

To load a UI file, use the function `PDUI:LoadUI(<UI scope>, <UI JSON file>);`. This function loads the UI into a fullscreen workspace.

To load a UI file into an existing element, use the function `PDUI:LoadSubUI(<parent element>, <UI scope>, <UI JSON file>);`

### Unloading UI files

To unload a UI file from the workspace, regardless of whether it was loaded into a panel or the workspace, use the function `PDUI:RemoveUI(<UI scope>);`,
the UI will be removed and unloaded from memory.