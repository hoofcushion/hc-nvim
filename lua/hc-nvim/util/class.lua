local Class={
 mts={},
}
function Class.get_mt(base)
 local mt=Class.mts[base]
 if mt==nil then
  mt={__index=base}
  Class.mts[base]=mt
 end
 return mt
end
---@generic T
---@param base T
---@return T|table
function Class.new(base)
 return setmetatable({},Class.get_mt(base))
end
function Class.set(base,class)
 setmetatable(base,Class.get_mt(class))
end
function Class.overload(base,operators)
 local mt=Class.get_mt(base)
 for k,v in pairs(operators) do
  mt[k]=v
 end
end
return Class
