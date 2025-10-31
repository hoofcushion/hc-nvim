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
-- :e for every file buffer
vim.api.nvim_create_autocmd("SafeState",{
 once=true,
 callback=function()
  local bufs=vim.api.nvim_list_bufs()
  for _,buf in ipairs(bufs) do
   if vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))~=nil then
    vim.api.nvim_buf_call(buf,vim.cmd.edit)
   end
  end
 end,
})
