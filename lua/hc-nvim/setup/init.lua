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
 "lsp",
}
for _,mod in ipairs(modules) do
 require("hc-nvim.setup."..mod)
end
