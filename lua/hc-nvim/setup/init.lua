local Util=require("hc-nvim.util")
vim.opt.rtp:append(Util.root_path)
_G.NS=require("hc-nvim.namespace")
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

vim.schedule(function()
 local bufs=vim.api.nvim_list_bufs()
 for _,buf in ipairs(bufs) do
  if vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))~=nil then
   vim.api.nvim_buf_call(buf,vim.cmd.edit)
  end
 end
end)
