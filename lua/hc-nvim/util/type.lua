---@class TypeDef
---@field attr string
---@field data any
---@class TypeOr:TypeDef
---@field attr "or"
---@field data TypeAny
---@class TypeAnd:TypeDef
---@field attr "and"
---@field data TypeAny
---@class TypeEnum:TypeDef
---@field attr "enum"
---@field data TypeAny
---@class TypeDynamic:TypeDef
---@field attr "dynamic"
---@field data {test:fun(x):boolean,desc:string}
---@class TypeTuple:TypeDef
---@field attr "tuple"
---@field data TypeAny
---@class TypeFunction:TypeDef
---@field attr "function"
---@field data {args:TypeAny,rets:TypeAny}
---@class TypeList:TypeDef
---@field attr "list"
---@field data TypeAny
---@class TypeDict:TypeDef
---@field attr "dict"
---@field data {k:TypeAny,v:TypeAny}
---@class TypeRecur:TypeDef
---@field attr "recur"
---@field data table<any,TypeAny>
---@alias TypeAny
---| TypeAny[]
---| any
---| type
---| TypeOr
---| TypeAnd
---| TypeEnum
---| TypeDynamic
---| TypeTuple
---| TypeFunction
---| TypeList
---| TypeDict
---| TypeRecur
---@class Type
local builtin_types={
 number=true,
 string=true,
 table=true,
 ["function"]=true,
 ["boolean"]=true,
 ["nil"]=true,
 ["userdata"]=true,
 ["thread"]=true,
}
local special_types={
 any=function ()
  return true
 end,
 ["true"]=function (x)
  return x==true
 end,
 ["false"]=function (x)
  return x==false
 end,
 integer=function (x)
  return type(x)=="number" and math.floor(x)==x
 end,
 decimal=function (x)
  return type(x)=="number" and math.floor(x)~=x
 end,
 nan=function (x)
  return x~=x
 end,
 ["truthy"]=function (x)
  return not not x
 end,
 ["falsy"]=function (x)
  return not x
 end,
}
local function type_check(x,tp)
 local tx=type(x)
 if builtin_types[tp] then
  return tx==tp
 end
 if special_types[tp] then
  return special_types[tp](x)
 end
 error("unrecognized type: "..tp)
end
local Type={
 attr=nil,
 data=nil,
}
function Type.def(attr,data)
 local obj=setmetatable({},{__index=Type})
 obj.attr=attr
 obj.data=data
 return obj
end
function Type:check(x)
 if self.attr=="or" then
  for _,v in ipairs(self.data) do
   if type_check(x,v) then
    return true
   end
  end
  return false
 elseif self.attr=="and" then
  for _,v in ipairs(self.data) do
   if not type_check(x,v) then
    return false
   end
  end
  return true
 end
end
print(Type.def("or",{"integer","decimal"}):check(1))
print(Type.def("or",{"integer","decimal"}):check(""))
function Type:assert()
end
function Type:wrap()
end
return Type
