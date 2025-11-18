local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.config.rsc")
local opts={
 defaults={
  layout_strategy="bottom_pane",
  layout_config={
   height=0.9999,
   preview_cutoff=120,
   prompt_position="top",
  },
  winblend=Config.ui.blend,
  sorting_strategy="ascending",
 },
 mappings={
  n={
   ["?"]=require("telescope.actions.generate").which_key({
    close_with_action=false,
   }),
  },
 },
}
opts.defaults=opts.defaults or {}
if Config.ui.border~="none" then
 opts.defaults.border=true
 -- convert neovim border list to telescope border list
 -- e.g:
 --  from {"┌","─","┐","│","┘","─","└","│"}
 --  to   {"─","│","─","│","╭","╮","╯","╰"}
 opts.defaults.borderchars=(function(t)
  return {t[2],t[4],t[6],t[8],t[1],t[3],t[5],t[7]}
 end)(Rsc.border[Config.ui.border])
else
 opts.defaults.border=false
end
return opts
