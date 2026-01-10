---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
function Util.type_assert(x,t,o)
 if type(x)==t or (o==true and x==nil) then
  return true
 end
 error(("Expect %s%s, got %s"):format(t,o and "?" or "",type(x)),2)
end
--- Like totable but return nil if input is a `empty table` or `nil`
---@return table?
function Util.try_to_list_else_nil(any)
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
