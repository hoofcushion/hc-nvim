local HCNvim=require("hc-nvim.init_space")
if false then
 ---@class server.handler
 local Handler={
  get_preset=nil, ---@type fun(name:string):table?
  setup=nil, ---@type fun(main:string,config:table)
 }
end
local Handler={}
local setuped={}
---
---@enum(key) handler_type
local handler_tab={
 lsp=require("hc-nvim.setup.server.handler.lsp"),
 null_ls=require("hc-nvim.setup.server.handler.null_ls"),
 dap=require("hc-nvim.setup.server.handler.dap"),
}
---@return handler_type?
function Handler.get_type(name)
 return handler_tab.lsp.get_preset(name)~=nil and "lsp"
  or handler_tab.null_ls.get_preset(name)~=nil and "null_ls"
  or handler_tab.dap.get_preset(name)~=nil and "dap"
  or nil
end
function Handler.get_config(modname)
 local info=require("hc-nvim.util").find_mod(
  ("hc-nvim.user.server.%s"):format(modname),
  ("hc-nvim.config.server.%s"):format(modname)
 )
 if info then
  return require(info.modname)
 end
end
function Handler.load(spec)
 local main=spec.main or spec.name
 local name=spec.name
 if setuped[main] then
  HCNvim.Util.WARN(debug.traceback("duplicate server setup call of "..spec.main))
  return
 end
 setuped[main]=true
 local ls_type=Handler.get_type(main)
 if ls_type and handler_tab[ls_type] then
  local config=Handler.get_config(name)
  handler_tab[ls_type].setup(main,config)
 end
end
return Handler
