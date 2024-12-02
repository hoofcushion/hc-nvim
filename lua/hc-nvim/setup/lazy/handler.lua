---@diagnostic disable: duplicate-set-field
--- Rewrite lazy.nvim to Load handlers lazily
local Handler=require("lazy.core.handler")
local Plugin=require("lazy.core.plugin")
local handler_event={
 keys="SafeState",
 cmd="SafeState",
}
for type,event in pairs(handler_event) do
 vim.api.nvim_create_autocmd(event,{
  once=true,
  callback=function()
   handler_event[type]=nil
  end,
 })
end
---@param plugin LazyPlugin
function Handler.enable(plugin)
 if plugin._.loaded then
  return
 end
 if plugin._.handlers==nil then
  plugin._.handlers={}
 end
 for type,handler in pairs(Handler.handlers) do
  if plugin[type]==nil then
   goto continue
  end
  local function add()
   if plugin._.loaded then
    return
   end
   plugin._.handlers[type]=handler:_values(Plugin.values(plugin,type,true),plugin)
   Handler.handlers[type]:add(plugin)
  end
  if handler_event[type] then
   --- Delay the handler's activation until the specified event is triggered
   vim.api.nvim_create_autocmd(handler_event[type],{
    once=true,
    callback=function()
     add()
    end,
   })
  else
   add()
  end
  ::continue::
 end
end
