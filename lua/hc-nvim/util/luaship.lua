local Util=require("hc-nvim.util")
--- 使用月球飞船模块隔离出一个空间，用于清理 Lua 插件造成的副作用
local LuaShip={}
function LuaShip.new(init)
 local obj=Util.Class.new(LuaShip)
 local _={}
 obj.record={}
 obj.init=init
 return obj
end
---@class LuaShip.regspec
local Reg={}
function LuaShip.register(regspec)
 LuaShip[regspec.name]=function(self,...)
  local operation={
   args=vim.F.pack_len(...),
   rets=vim.F.pack_len(regspec.create(...)),
   destroy=regspec.destroy,
  }
  table.insert(self.record,operation)
  return vim.F.unpack_len(operation.rets)
 end
end
LuaShip.register({
 name="bufadd",
 create=function(name)
  return vim.fn.bufadd(name)
 end,
 destroy=function(spec)
  local buffer=spec.rets[1]
  if buffer~=0 and vim.api.nvim_buf_is_valid(buffer) then
   return vim.api.nvim_buf_delete(buffer,{force=true})
  end
 end,
})
LuaShip.register({
 name="create_autocmd",
 create=function(event,opts)
  return vim.api.nvim_create_autocmd(event,opts)
 end,
 destroy=function(spec)
  local id=spec.rets[1]
  pcall(vim.api.nvim_del_autocmd,id)
 end,
})
function LuaShip:fini()
 for _,spec in ipairs(self.record) do
  spec:destroy(spec)
 end
end
if true then
 local ship=LuaShip.new()
 local buf=ship:bufadd("test buffer")
 local id=ship:create_autocmd("SafeState",{
  command="echo autocmd",
 })
 ship:fini()
end
return LuaShip
