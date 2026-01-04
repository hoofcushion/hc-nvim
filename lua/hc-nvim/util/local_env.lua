---@class LocalEnv.scope
local Scope={}
-- validate id
function Scope.validate(id) end
-- get default id
function Scope.default() return 0 end
-- register a cleanup function
function Scope.register(env,id) end
Scope.parent={} ---@type vim.var_accessor
---@type LocalEnv.scope
local bufScope={
 parent=vim.b,
 validate=vim.api.nvim_buf_is_valid,
 default=vim.api.nvim_get_current_buf,
 register=function(env,id)
  vim.api.nvim_create_autocmd("BufDelete",{
   once=true,
   buffer=id,
   callback=function(event)
    env[event.buf]=nil
   end,
  })
 end,
}
---@type LocalEnv.scope
local winScope={
 parent=vim.w,
 validate=vim.api.nvim_win_is_valid,
 default=vim.api.nvim_get_current_win,
 register=function(env,id)
  vim.api.nvim_create_autocmd("WinClosed",{
   once=true,
   pattern=id,
   callback=function(event)
    env[event.match]=nil
   end,
  })
 end,
}
---@type LocalEnv.scope
local tabScope={
 parent=vim.t,
 validate=vim.api.nvim_tabpage_is_valid,
 default=vim.api.nvim_get_current_tabpage,
 register=function(env,id)
  vim.api.nvim_create_autocmd("TabClosed",{
   once=true,
   pattern=id,
   callback=function(event)
    env[event.match]=nil
   end,
  })
 end,
}
---@alias LocalEnv.scope_names
---| "buffer"
---| "window"
---| "tab"
--- LocalEnv give individual local environments for buffer, window and tabpage to replace viml traditional b: w: t:
---@type table<LocalEnv.scope_names,LocalEnv.scope>
local scopes={
 buffer=bufScope,
 window=winScope,
 tabpage=tabScope,
}
---@param scope LocalEnv.scope
local function make_env(scope)
 ---@type table<integer,table>
 local env={}
 --- get vars table of that id in env
 local function vars(id)
  local ret=env[id]
  if not ret then
   ret=setmetatable({},{
    __index=function(t,k)
     local v=rawget(t,k)
     if v==nil then
      v=scope.parent[k]
     end
     return v
    end,
   })
   env[id]=ret
   scope.register(env,id)
  end
  return ret
 end
 return setmetatable({},{
  __newindex=function(_,k,v)
   vars(scope.default())[k]=v
  end,
  __index=function(_,k)
   if type(k)=="number" and scope.validate(k) then
    return vars(k)
   end
   return vars(scope.default())[k]
  end,
 })
end
---@class LocalEnv
local LocalEnv={}
-- luals type annotations
if false then
 LocalEnv.buffer=vim.b
 LocalEnv.window=vim.w
 LocalEnv.tabpage=vim.t
end
function LocalEnv:reset()
 for k,v in pairs(scopes) do
  self[k]=make_env(v)
 end
end
function LocalEnv.new()
 local obj=setmetatable({},{__index=LocalEnv})
 obj:reset()
 return obj
end
return LocalEnv
