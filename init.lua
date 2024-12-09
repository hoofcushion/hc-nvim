--- hc-nvim/init.lua
--- You can use this file as a starter for hc-nvim
require("bootstrap")
require("lazy").setup({
 spec={
  {import="hc-nvim.export"},
 },
 default={
  lazy=true,
 },
})
