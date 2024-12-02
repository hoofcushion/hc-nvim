local Config=require("hc-nvim.config")
return {
 size=function(term)
  return Config.ui.window:dynamic(term.direction)
 end,
 direction="float",
 float_opts={
  border=Config.ui.border,
  width=Config.ui.window:dynamic("width"),
  height=Config.ui.window:dynamic("height"),
 },
}
