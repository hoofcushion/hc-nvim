--- ---
--- hc-nvim/lua/hc-nvim/init.lua
--- ---
--- warn user to not load this file as a lazy.nvim plugin
--- ---
local M={}
M.Config=require("hc-nvim.config")
M.Util=require("hc-nvim.util")
M.Rsc=require("hc-nvim.rsc")
return M
