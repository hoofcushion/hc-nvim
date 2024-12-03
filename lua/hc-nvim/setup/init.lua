local Util=require("hc-nvim.util")
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
 require("hc-nvim.setup."..modname)
 Util.track()
end
