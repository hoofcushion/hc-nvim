---@diagnostic disable: unused-local
---@class LocalEnv.Scope
local Scope={
 env=nil, ---@type table<integer,table>
 parent=nil, ---@type vim.var_accessor
}
-- validate id
function Scope.validate(id) end
-- get default id
function Scope.default() return 0 end
-- register a cleannup
function Scope.register(env,id) end
Scope.__index=Scope
-- a private table key
local PRIVATE={}
-- static metatable
local vars_metamethod={
 __index=function(t,k)
  local self=rawget(t,PRIVATE)
  local v=rawget(t,k)
  if v==nil then
   v=self.parent[k]
  end
  return v
 end,
}
function Scope:vars(id)
 local ret=self.env[id]
 if not ret then
  ret=setmetatable({[PRIVATE]=self},vars_metamethod)
  self.env[id]=ret
  self.register(self,id)
 end
 return ret
end
-- static metatable
local scope_metatable={
 __newindex=function(t,k,v)
  local self=rawget(t,PRIVATE)
  self:vars(self.default())[k]=v
 end,
 __index=function(t,k)
  local self=rawget(t,PRIVATE)
  if type(k)=="number" and self.validate(k) then
   return self:vars(k)
  end
  return self:vars(self.default())[k]
 end,
}
-- generate a scope instance
function Scope:setup()
 self.env={}
 return setmetatable({[PRIVATE]=self},scope_metatable)
end
-- to make Scope derivation
function Scope.new()
 return setmetatable({},Scope)
end
-- a autocmd callback window
-- with a lua gc bind
local function new_autocmd_window(events,opts)
 local fns={}
 opts.callback=function(ev)
  for key,fn in pairs(fns) do
   local ok,clear=pcall(fn,ev)
   if not ok or clear then
    fn[key]=nil
   end
  end
 end
 local id=vim.api.nvim_create_autocmd(events,opts)
 if not id then error("Unreachable") end
 local ud=newproxy(true)
 getmetatable(ud).__gc=function()
  pcall(vim.api.nvim_del_autocmd,id)
 end
 return {
  [PRIVATE]=ud,
  append=function(fn)
   table.insert(fns,fn)
  end,
 }
end

--- initialize scopes

---@type LocalEnv.Scope
local bufScope=Scope.new(); do
 bufScope.parent=vim.b
 bufScope.validate=vim.api.nvim_buf_is_valid
 bufScope.default=vim.api.nvim_get_current_buf
 local buf_cleannup_window=new_autocmd_window("BufDelete",{
  group=vim.api.nvim_create_augroup("LocalEnv_buffer_Cleannup",{}),
 })
 function bufScope:register(id)
  buf_cleannup_window.append(function(event)
   if id==tonumber(event.buf) then
    self.env[id]=nil
    return true
   end
  end)
 end
end
---@type LocalEnv.Scope
local winScope=Scope.new(); do
 winScope.parent=vim.w
 winScope.validate=vim.api.nvim_win_is_valid
 winScope.default=vim.api.nvim_get_current_win
 local window_cleannup_window=new_autocmd_window("WinClosed",{
  group=vim.api.nvim_create_augroup("LocalEnv_window_Cleannup",{}),
 })
 function winScope:register(id)
  window_cleannup_window.append(function(event)
   if id==tonumber(event.match) then
    self.env[id]=nil
   end
  end)
 end
end
---@type LocalEnv.Scope
local tabScope=Scope.new(); do
 tabScope.parent=vim.t
 tabScope.validate=vim.api.nvim_tabpage_is_valid
 tabScope.default=vim.api.nvim_get_current_tabpage
 local tab_cleannup_window=new_autocmd_window("TabClosed",{
  group=vim.api.nvim_create_augroup("LocalEnv_tabState_Cleannup",{}),
 })
 function tabScope:register(id)
  tab_cleannup_window.append(function(event)
   if id==tonumber(event.match) then
    self.env[id]=nil
    return true
   end
  end)
 end
end
--- LocalEnv give individual local environments for buffer, window and tabpage to replace viml traditional b: w: t:
local scopes={
 buffer=bufScope,
 window=winScope,
 tabpage=tabScope,
}
---@class LocalEnv
local LocalEnv={}
-- luals type annotations
if false then
 LocalEnv.buffer=vim.b
 LocalEnv.window=vim.w
 LocalEnv.tabpage=vim.t
end
-- reset all scopes
function LocalEnv:reset()
 for name,scope in pairs(scopes) do
  self[name]=scope:setup()
 end
end
-- get a new LocalEnv instance
-- to read and write buffer local variable via LocalEnv.buffer.xxx = ...
-- available scopes are `buffer` `window` `tabpage`
-- to clear all scope, use `:reset()`
function LocalEnv.new()
 local obj=setmetatable({},{__index=LocalEnv})
 obj:reset()
 return obj
end
if LUAFILE then
 local localenv=LocalEnv.new()
 local b=0
 localenv.buffer[b].a=1
 print(localenv.buffer[b].a)
 localenv:reset()
 print(localenv.buffer[b].a)
end
return LocalEnv
