local Util=require("hc-nvim.util.init_space")
local LazyTab={}
---@return {}
function LazyTab.create(tbl)
 local ret=Util.Cache.table(function(name)
  name=tbl[name]
  if name then
   return require(name)
  end
 end)
 return ret
end
---@generic T:table
---@param fn fun():T
---@return T
function LazyTab.from(fn)
 -- fake require
 debug.setfenv(fn,{
  require=function(...)
   return ...
  end,
 })
 return LazyTab.create(fn())
end
-- Example
if false then
 local t=LazyTab.from(function()
  return {
   x=require("init"),
  }
 end)
 -- lazy require
 print(t.x)
end
return LazyTab
