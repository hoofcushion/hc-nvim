---@class config
---@field names boolean: Enables named colors (e.g., "Blue").
---@field names_opts table: Names options for customizing casing, digit stripping, etc
---@field names_custom table|function|false: Custom color name to RGB value mappings
---@field RGB boolean: Enables `#RGB` hex codes.
---@field RGBA boolean: Enables `#RGBA` hex codes.
---@field RRGGBB boolean: Enables `#RRGGBB` hex codes.
---@field RRGGBBAA boolean: Enables `#RRGGBBAA` hex codes.
---@field AARRGGBB boolean: Enables `0xAARRGGBB` hex codes.
---@field rgb_fn boolean: Enables CSS `rgb()` and `rgba()` functions.
---@field hsl_fn boolean: Enables CSS `hsl()` and `hsla()` functions.
---@field css boolean: Enables all CSS features (`rgb_fn`, `hsl_fn`, `names`, `RGB`, `RRGGBB`).
---@field css_fn boolean: Enables all CSS functions (`rgb_fn`, `hsl_fn`).
---@field tailwind boolean|string: Enables Tailwind CSS colors (e.g., `"normal"`, `"lsp"`, `"both"`).
---@field tailwind_opts table: Tailwind options for updating names cache, etc
---@field sass table: Sass color configuration (`enable` flag and `parsers`).
---@field mode 'background'|'foreground'|'virtualtext': Display mode
---@field virtualtext string: Character used for virtual text display.
---@field virtualtext_inline boolean|'before'|'after': Shows virtual text inline with color.
---@field virtualtext_mode 'background'|'foreground': Mode for virtual text display.
---@field always_update boolean: Always update color values, even if buffer is not focused.
---@field hooks table: Table of hook functions
---@field hooks.disable_line_highlight function: Returns boolean which controls if line should be parsed for highlights
---@field xterm boolean: Enables xterm 256-color codes (#xNN, \e[38;5;NNNm)
return {
 names=true,
 names_opts={
  lowercase=true,
  camelcase=true,
  uppercase=true,
  strip_digits=true,
 },
 RGB=true,
 RGBA=true,
 RRGGBB=true,
 RRGGBBAA=true,
 AARRGGBB=true,
}
