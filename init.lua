--- hc-nvim/init.lua
--- use this file as a distro starter for hc-nvim
require("bootstrap")
require("lazy").setup({
 spec={
  {import="hc-nvim.export"},
 },
 default={
  lazy=true,
 },
})
