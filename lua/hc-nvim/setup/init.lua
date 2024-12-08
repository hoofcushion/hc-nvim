local Util=require("hc-nvim.util")
--- PERF: load builtins with
local raw=require
require=Util.lua_ls_alias(raw,function(modname)
 if Util.startswith(modname,"hc-nvim.builtin") then
  return Util.load_local_mod(modname)
 end
 return raw(modname)
end)
vim.opt.rtp:append(Util.root_path)
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
 Util.load_local_mod("hc-nvim.setup."..modname)
 Util.track()
end
require=raw
