--- ---
--- hc-nvim/lua/hc-nvim/export.lua
--- ---
--- import this file in lazy.nvim to use hc-nvim as a plugin source
--- ---
local hcnvim=require("hc-nvim")
hcnvim.setup()
return hcnvim.export()
