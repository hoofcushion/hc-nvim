local Cache=require("hc-func.util.cache")
local LazyTab={}
---@return table
function LazyTab.create(tbl)
 local ret=Cache.table(function(name)
  return require(tbl[name])
 end)
 return ret
end
return LazyTab
