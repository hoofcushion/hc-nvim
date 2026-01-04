local Config=require("hc-nvim.config")
return {
 size=function(term)
  return Config.ui.size:dynamic(term.direction)
 end,
 direction="float",
 float_opts={
  border=Config.ui.border,
  width=Config.ui.size:dynamic("width"),
  height=Config.ui.size:dynamic("height"),
 },
}
