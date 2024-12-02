local Cache=require("hc-nvim.util.cache")
local LazyTab={}
---@return {}
function LazyTab.create(tbl)
 local ret=Cache.table(function(name)
  name=tbl[name]
  if name then
   return require(name)
  end
 end)
 return ret
end
return LazyTab
