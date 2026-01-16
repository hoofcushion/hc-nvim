local Util=require("hc-nvim.util.init_space")
---@class Wrapper
local M={}
---@generic T
---@param opts T
---@param init fun(opts:T)
---@return fun():T
function M.with_initialize(opts,init)
 return function()
  init(opts)
  return opts
 end
end
---@param cond fun():boolean
---@param lhs function?
---@param rhs function?
function M.fn_cond(cond,lhs,rhs)
 return function()
  if cond() then
   return lhs and lhs() or nil
  else
   return rhs and rhs() or nil
  end
 end
end
function M.fn_with(fn,...)
 local pack1=Util.packlen(...)
 return function(...)
  local pack2=Util.packlen(...)
  local pack=Util.packenxtend(pack1,pack2)
  return fn(Util.unpacklen(pack))
 end
end
---@param val any
---@return function
function M.self(val)
 val=Util.deepcopy(val)
 return function()
  return Util.deepcopy(val)
 end
end
---@param fn function
---@param expr any
---@param oppo boolean?
function M.fn_eval(fn,expr,oppo)
 if expr==nil then
  return fn
 end
 if type(expr)~="function" then
  expr=M.self(expr)
 end
 if oppo then
  local _expr=expr
  expr=function(...)
   return not _expr(...)
  end
 end
 return function()
  return fn(expr())
 end
end
function M.curring(fn,arg)
 return function(...)
  return fn(arg,...)
 end
end
function M.combine(...)
 local fns={...}
 return function()
  for _,fn in ipairs(fns) do
   if type(fn)=="function" then
    fn()
   end
  end
 end
end
---@param name string
---@param states any[]|nil
---@return fun():nil toggler
function M.toggle_option(name,states)
 if states~=nil then
  local i,len=0,#states
  local function toggle()
   i=i%len+1
   if vim.opt[name]==states[i] then
    toggle()
    return
   end
   vim.opt[name]=states[i]
  end
  return toggle
 end
 return function()
  vim.o[name]=not vim.o[name]
 end
end
return M
