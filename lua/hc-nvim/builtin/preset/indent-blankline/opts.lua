local Config=require("hc-nvim.config")
local rainbow=require("hc-nvim.misc.rainbow").create(7,25,50)
return {
 indent={
  char="│",
  tab_char="┃",
  highlight=rainbow,
 },
 whitespace={
  highlight=rainbow,
 },
 scope={
  enabled=true,
  show_start=true,
  show_end=true,
  char="┃",
  injected_languages=true,
  highlight=rainbow,
 },
 exclude={
  filetypes=Config.performance.exclude.filetypes,
  buftypes=Config.performance.exclude.buftypes,
 },
}
