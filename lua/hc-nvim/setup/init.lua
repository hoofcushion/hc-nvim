--- Track cycle require
local Util=require("hc-nvim.util")
-- init plugin rtp
vim.opt.rtp:append(Util.root_path)
-- init NS for string reference
_G.NS=Util.namespace
-- load modules
local modules={
 "i18n",
 "option",
 "basic",
 "event",
 "mapping",
 "filetype",
 "lazy",
 "vscode",
 "server",
}
for _,modname in ipairs(modules) do
 Util.track(modname)
 Util.try(function()
  return require("hc-nvim.setup."..modname)
 end,Util.ERROR)
 Util.track()
end
