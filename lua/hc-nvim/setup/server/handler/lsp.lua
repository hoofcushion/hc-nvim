---@type server.handler
local M={}
function M.get_preset(name)
 local configs=vim.api.nvim_get_runtime_file(("lsp/%s.lua"):format(name),false)
 if next(configs)==nil then
  return
 end
 local ret=vim.lsp.config[name]
 if ret~=nil then
  return ret
 end
 return nil
end
function M.setup(name,config)
 if config then
  vim.lsp.config(name,config)
 end
 vim.lsp.enable(name)
end
return M
