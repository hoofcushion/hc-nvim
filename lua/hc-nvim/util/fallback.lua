local Util=require("hc-nvim.util.init_space")
local Fallback={}
--- return a table that will try to index `tbl` and using `default` as fallback
function Fallback.create(default,tbl)
 if type(default)~="table" then
  return default
 end
 if type(tbl)~="table" then
  return tbl~=nil and tbl or default
 end
 return Util.Cache.table(function(k)
  return Fallback.create(default[k],tbl[k])
 end)
end
return Fallback
