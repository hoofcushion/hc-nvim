local Util=require("hc-nvim.util.init_space")
local Fallback={}
--- return a table that will try to index `tbl` and using `default` as fallback
function Fallback.create(default,value)
 if type(default)~="table" then
  return value or default
 end
 if type(value)~="table" then
  return value or default
 end
 return setmetatable({},{
  __index=function(_,k)
   return Fallback.create(default[k],value[k])
  end,
 })
end
-- local a={b=2}
-- local b={b=1}
-- local c=Fallback.create(a,b)
-- print(c.b) -- 1
-- b.b=3
-- print(c.b) -- 3
-- a.b=4
-- print(c.b) -- 3
return Fallback
