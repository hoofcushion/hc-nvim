---@class Wrapper
local M={}
function M.modifier(opts,fn)
 return function()
  fn(opts)
  return opts
 end
end
function M.fn_cond(cond,fn1,fn2)
 if fn2==nil then
  return function()
   if cond() then
    return fn1()
   end
  end
 end
 return function()
  if cond() then
   return fn1()
  else
   return fn2()
  end
 end
end
function M.fn(fn,arg1,arg2)
 if arg1==nil then
  return fn
 end
 if arg2==nil then
  return function()
   return fn(arg1)
  end
 end
 return function()
  return fn(arg1,arg2)
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
 local t=type(val)
 if t=="table" then
  return function()
   return vim.deepcopy(val)
  end
 end
 return function()
  return val
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
function M.method(fn,obj,opts)
 if opts==nil then
  return function()
   return fn(obj)
  end
 end
 return function()
  return fn(obj,opts)
 end
end
function M.fn2(fn1,fn2)
 return function()
  fn1()
  fn2()
 end
end
function M.fn_it(fn,prompt)
 return function()
  local input=vim.fn.input(prompt)
  return fn(input)
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
