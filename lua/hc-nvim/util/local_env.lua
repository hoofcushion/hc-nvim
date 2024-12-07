local Util=require("hc-nvim.util")
--- LocalEnv give individual local environments buffer, window, tabpage base on its unique id for each module
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
 },
}
local function make_env(info,id)
 ---@type table<integer,table>
 local env=setmetatable({},{
  __newindex=function(t,k,v)
   info.destroy(t,k)
   rawset(t,k,v)
  end,
 })
 return setmetatable({},{
  __newindex=function(_,k,v)
   Util.tbl_check(env,id or info.current())[k]=v
  end,
  __index=function(_,k)
   if id==nil and type(k)=="number" and info.validate(k) then
    return make_env(info,k)
   end
   return Util.tbl_check(env,id or info.current())[k]
  end,
 })
end
---@class LocalEnv
---@field window vim.var_accessor
---@field buffer vim.var_accessor
---@field tab vim.var_accessor
local LocalEnv={
 buffer=vim.b,
 window=vim.w,
 tab=vim.t,
}
function LocalEnv:reset()
 for k,v in pairs(scopes) do
  self[k]=make_env(v)
 end
end
function LocalEnv.new()
 local obj=Util.Class.new(LocalEnv)
 obj:reset()
 return obj
end
return LocalEnv
