local Util=require("hc-nvim.util.init_space")
---@class Wrapper
local M={}
function M.modifier(opts,fn)
 return function()
  fn(opts)
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
 local args=Util.packlen(...)
 return function()
  return fn(Util.unpacklen(args))
 end
end
function M.fn_states(fn,state)
 local i,max=0,#state
 return function()
  i=i%max+1
  return fn(state[i])
 end
end
function M.fn_seq(...)
 local fns={...}
 local i,max=1,#fns
 local fn=fns[i]
 return function()
  local ret=fn()
  i=i%max+1
  fn=fns[i]
  return ret
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
function M.method(obj,fn)
 return function(...)
  return fn(obj,...)
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
---@param cmd string 要执行的 Neovim 命令
---@return fun():nil
function M.cmd(cmd)
 return function()
  vim.api.nvim_command(cmd)
 end
end
return M
