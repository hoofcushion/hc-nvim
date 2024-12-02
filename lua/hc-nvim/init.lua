--- ---
--- hc-nvim/lua/hc-nvim/init.lua
--- ---
--- warn user to not load this file as a lazy.nvim plugin
--- ---
local M={}
function M.setup()
 vim.notify([[You should import hc-nvim by using {"hoofcushion/hc-nvim",import="hc-nvim.export"}]])
end
return M
