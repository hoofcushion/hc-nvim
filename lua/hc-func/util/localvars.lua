local Class=require("hc-func.class")
---@enum (key) localvars.scope
local scopes={
 buffer={
  validate=vim.api.nvim_buf_is_valid,
  current=vim.api.nvim_get_current_buf,
  destroy=function(vars,id)
   vim.api.nvim_create_autocmd({"BufDelete","BufWipeOut"},{
    once=true,
    buffer=id,
    callback=function(event)
     vars[event.buf]=nil
    end,
   })
  end,
  fallback=vim.b,
 },
 window={
  validate=vim.api.nvim_win_is_valid,
  current=vim.api.nvim_get_current_win,
  destroy=function(vars,id)
   vim.api.nvim_create_autocmd("WinClosed",{
    once=true,
    pattern=tostring(id),
    callback=function(event)
     vars[event.match]=nil
    end,
   })
  end,
  fallback=vim.w,
 },
 tab={
  validate=vim.api.nvim_tabpage_is_valid,
  current=vim.api.nvim_get_current_tabpage,
  destroy=function(vars,id)
   vim.api.nvim_create_autocmd("TabClosed",{
    once=true,
    pattern=tostring(id),
    callback=function(event)
     vars[event.match]=nil
    end,
   })
  end,
  fallback=vim.t,
 },
}
local function tbl_check(t,k)
 local ret=t[k]
 if ret==nil then
  ret={}
  t[k]=ret
 end
 return ret
end
local function mk_var_accessor(scope,id)
 local info=scopes[scope]
 local vars=setmetatable({},{
  __newindex=function(t,k,v)
   info.destroy(t,k)
   rawset(t,k,v)
  end,
 })
 local mt={}
 function mt:__newindex(key,value)
  tbl_check(vars,id or info.current())[key]=value
 end
 function mt:__index(key)
  if id==nil and type(key)=="number" and info.validate(key) then
   return mk_var_accessor(scope,key)
  end
  return tbl_check(vars,id or info.current())[key]
 end
 return setmetatable({},mt)
end
---@class localvars
---@field window vim.var_accessor
---@field buffer vim.var_accessor
---@field tab vim.var_accessor
local M={
 buffer=vim.b,
 window=vim.w,
 tab=vim.t,
}
function M:reset()
 for scope in pairs(scopes) do
  self[scope]=mk_var_accessor(scope)
 end
end
---@return localvars
function M.create()
 local obj=Class.new(M)
 obj:reset()
 return obj
end
return M
