--- ---
--- hc-nvim/lua/hc-nvim/export.lua
--- ---
--- import this file in lazy.nvim to use hc-nvim as a plugin source
--- ---
local HCNvim=require("hc-nvim")
HCNvim.setup()
return HCNvim.Setup.Lazy.Specs
