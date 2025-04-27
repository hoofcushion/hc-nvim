local opts={
 defaults={
  layout_strategy="bottom_pane",
  winblend=10,
  sorting_strategy="ascending",
 },
}
local config=require("hc-nvim.config")
local rsc=require("hc-nvim.rsc")
opts.defaults=opts.defaults or {}
if config.ui.border~="none" then
 opts.defaults.border=true
 -- convert neovim border list to telescope border list
 -- e.g:
 --  from {"┌","─","┐","│","┘","─","└","│"}
 --  to   {"─","│","─","│","╭","╮","╯","╰"}
 opts.defaults.borderchars=(function(t)
  return {t[2],t[4],t[6],t[8],t[1],t[3],t[5],t[7]}
 end)(rsc.border[config.ui.border])
else
 opts.defaults.border=false
end
return opts
