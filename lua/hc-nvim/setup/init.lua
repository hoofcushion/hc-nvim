local Util=require("hc-nvim.util")
vim.opt.rtp:append(Util.root_path)
_G.NS=require("hc-nvim.namespace")
local raw=require
require=Util.lua_ls_alias(raw,function(modname)
 if Util.startswith(modname,"hc-nvim.builtin") then
  return Util.local_require(modname)
 end
 return raw(modname)
end)
Util.BufferCache.setup()
local modules={
 "i18n",
 "option",
 "mapping",
 "autocmd",
 "filetype",
 "diagnostic",
 "lazy",
 "vscode",
 "server",
}
for _,modname in ipairs(modules) do
 Util.track(modname)
 require("hc-nvim.setup."..modname)
 Util.track()
end
require=raw
