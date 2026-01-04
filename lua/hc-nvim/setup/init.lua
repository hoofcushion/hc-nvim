--- Track cycle require
local Util=require("hc-nvim.util")
-- init plugin rtp
vim.opt.rtp:append(Util.root_path)
-- init NS for string reference
_G.NS=Util.namespace
-- load modules
local modules={
 "i18n",     -- load language packs
 "option",   -- set neovim options
 "basic",    -- run basic setup scripts
 "filetype", -- load custom filetypes
 "event",    -- register custom events
 "mapping",  -- register keymaps
 "lazy",     -- load lazy.nvim plugin configs
 "vscode",   -- load extra vscode-neovim setting
 "server",   -- load language tools settings
}
for _,modname in ipairs(modules) do
 Util.track(modname)
 Util.try(function()
  return require("hc-nvim.setup."..modname)
 end,Util.ERROR)
 Util.track()
end
