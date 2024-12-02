local Class={}
local mts={}
---@generic T
---@param base T
---@return T|table
function Class.new(base,new,ops)
 if new==nil then
  new={}
 end
 local mt=mts[base] -- same class with same mt
 if mt==nil then
  mt={__index=base}
  --- overload operators
  if ops then
   for k,v in pairs(ops) do
    mt[k]=v
   end
  end
  mts[base]=mt
 end
 return setmetatable(new,mt)
end
return Class
