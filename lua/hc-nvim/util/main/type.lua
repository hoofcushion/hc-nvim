---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
function Util.validate(x,t,o)
 if type(x)==t or (o==true and x==nil) then
  return true
 end
 error(("Expect %s%s, got %s"):format(t,o and "?" or "",type(x)))
end
---@param tbl table
---@return integer
function Util.count(tbl)
 local count=0
 for _ in pairs(tbl) do
  count=count+1
 end
 return count
end
---@param tbl table
---@return boolean
function Util.is_list(tbl)
 local i=0
 for _ in pairs(tbl) do
  i=i+1
  if tbl[i]==nil then
   return false
  end
 end
 return true
end
--- Like totable but return nil if input is a `empty table` or `nil`
---@return table?
function Util.to_fat_table(any)
 if type(any)~="table" then
  if any~=nil then
   return {any}
  end
  return
 end
 if next(any)~=nil then
  return any
 end
end
--- Return true if input is truthy value, otherwise return false
---@param val any
---@return boolean
function Util.toboolean(val)
 return val~=nil and val~=false
end
--- Return a table with one element if input is not a table, otherwise return the input table.
---@generic T
---@param any T
---@return T[]
function Util.totable(any)
 if type(any)~="table" then
  return {any}
 end
 return any
end
