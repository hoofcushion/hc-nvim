---@enum (key) builtin_types
local builtin_types={
 number=true,
 string=true,
 table=true,
 ["function"]=true,
 ["boolean"]=true,
 ["nil"]=true,
 ["userdata"]=true,
 ["thread"]=true,
 any=function()
  return true
 end,
 ["true"]=function(x)
  return x==true
 end,
 ["false"]=function(x)
  return x==false
 end,
 integer=function(x)
  return type(x)=="number" and math.floor(x)==x
 end,
 decimal=function(x)
  return type(x)=="number" and math.floor(x)~=x
 end,
 positive=function(x)
  return type(x)=="number" and x>0
 end,
 negative=function(x)
  return type(x)=="number" and x<0
 end,
 number_get0=function(x)
  return type(x)=="number" and x>=0
 end,
 number_let0=function(x)
  return type(x)=="number" and x<=0
 end,
 even_number=function(x)
  return type(x)=="number" and math.floor(x)==x and x%2==0
 end,
 odd_number=function(x)
  return type(x)=="number" and math.floor(x)==x and x%2==1
 end,
 nan=function(x)
  return x~=x
 end,
 ["truthy"]=function(x)
  return not not x
 end,
 ["falsy"]=function(x)
  return not x
 end,
}
---@enum Type.attrs
local attrs={
 base="base",
 value="value",
 any="any",
 all="all",
 non="non",
 custom="custom",
 list="list",
 dict="dict",
 struct="struct",
 tuple="tuple",
 func="func",
}
local recur_attrs={
 list=true,
 dict=true,
 struct=true,
 tuple=true,
 func=true,
}
local unpack=unpack or table.unpack
---@class Type
local Type={
 attr=nil, ---@type Type.attrs
 data=nil, ---@type any
}
---@private
function Type._guess(value)
 if builtin_types[value] then
  return Type._exact(attrs.base,value)
 end
 if type(value)=="table" then
  if value.attr and value.data then
   return value
  else
   return Type._exact(attrs.struct,value)
  end
 end
 if type(value)=="function" then
  return Type._exact(attrs.custom,{info="unknown",check=value})
 end
 return Type._exact(attrs.value,value)
end
---@private
function Type._exact(attr,data)
 local obj=setmetatable({},{__index=Type})
 obj.attr=attr
 obj.data=data
 if attr==attrs.any or attr==attrs.all then
  local t={}
  for i,v in ipairs(data) do
   t[i]=Type.new(v)
  end
  obj.data=t
 elseif attr==attrs.non then
  obj.data=Type.new(data)
 elseif attr==attrs.list then
  obj.data=Type.new(data)
 elseif attr==attrs.dict then
  obj.data={k=Type.new(data.k),v=Type.new(data.v)}
 elseif attr==attrs.struct then
  local t={}
  for k,v in pairs(data) do
   t[k]=Type.new(v)
  end
  obj.data=t
 elseif attr==attrs.tuple then
  local processed={
   fixed={},
   vararg=data.vararg and Type.new(data.vararg) or nil,
  }
  for i,v in ipairs(data.fixed or {}) do
   processed.fixed[i]=Type.new(v)
  end
  obj.data=processed
 elseif attr==attrs.func then
  obj.data={
   args=Type.new(data.args),
   rets=Type.new(data.rets),
  }
 end
 return obj
end
local function connect_index(name,key)
 if type(key)=="string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
  return name.."."..key
 else
  return name.."["..("%q"):format(key).."]"
 end
end
local function format_list(list)
 local t={}
 for _,v in ipairs(list) do
  table.insert(v,v:format())
 end
 if next(t)==nil then
  table.insert(t,"empty")
 end
 return table.concat(t,", ")
end
function Type:format()
 if self.attr==attrs.base then
  return self.data
 elseif self.attr==attrs.value then
  return tostring(self.data)
 elseif self.attr==attrs.any then
  return "any<"..format_list(self.data)..">"
 elseif self.attr==attrs.all then
  return "all<"..format_list(self.data)..">"
 elseif self.attr==attrs.non then
  return "non<"..self.data:format()..">"
 elseif self.attr==attrs.custom then
  return "custom<"..tostring(self.data.info)..">"
 elseif self.attr==attrs.list then
  return "list<"..self.data:format()..">"
 elseif self.attr==attrs.dict then
  return "dict<k:"..self.data.k:format()..", v:"..self.data.v:format()..">"
 elseif self.attr==attrs.struct then
  local fields={}
  for k,v in pairs(self.data) do
   table.insert(fields,string.format("%s=%s",tostring(k),v:format()))
  end
  return "table<"..table.concat(fields,", ")..">"
 elseif self.attr==attrs.tuple then
  local parts={}
  for _,t in ipairs(self.data.fixed) do
   table.insert(parts,t:format())
  end
  if self.data.vararg then
   table.insert(parts,"..."..self.data.vararg:format())
  end
  return "("..table.concat(parts,", ")..")"
 elseif self.attr==attrs.func then
  return "function("..self.data.args:format().."): "..self.data.rets:format()
 else
  return "<unknown>"
 end
end
local function format_value(value)
 return type(value)=="string" and ("%q"):format(value) or tostring(value)
end
function Type:msg(name,value)
 if not recur_attrs[self.attr] then
  value=value~=nil and format_value(value) or nil
  return string.format("Expected %s for %s, got %s",self:format(),name,value)
 end
 error("Invalid `Type:msg()` call")
end
---@type table<Type.attrs,fun(self:Type,name:string,got:any):boolean,string?>
local checks={
 [attrs.base]=function(self,name,got)
  local checker=builtin_types[self.data]
  if type(checker)=="function" then
   if not checker(got) then
    return false,self:msg(name,got)
   end
   return true
  else
   if type(got)~=self.data then
    return false,self:msg(name,got)
   end
   return true
  end
 end,
 [attrs.value]=function(self,name,got)
  if got~=self.data then
   return false,self:msg(name,got)
  end
  return true
 end,
 [attrs.any]=function(self,name,got)
  for _,type_any in ipairs(self.data) do
   if type_any:check(name,got) then
    return true
   end
  end
  return false,self:msg(name,got)
 end,
 [attrs.all]=function(self,name,got)
  if #self.data==0 then
   return true
  end
  for _,type_all in ipairs(self.data) do
   local success=type_all:check(name,got)
   if not success then
    return false,self:msg(name,got)
   end
  end
  return true
 end,
 [attrs.non]=function(self,name,got)
  if self.data:check(name,got) then
   return false,self:msg(name,got)
  end
  return true
 end,
 [attrs.custom]=function(self,name,got)
  if not self.data.check(got) then
   return false,self:msg(name,got)
  end
  return true
 end,
 [attrs.list]=function(self,name,got)
  local ok,err=Type.check_type("table",name,got)
  if not ok then
   return ok,err
  end
  for i,item in ipairs(got) do
   local success,msg=self.data:check(connect_index(name,i),item)
   if not success then
    return false,msg
   end
  end
  return true
 end,
 [attrs.dict]=function(self,name,got)
  local ok,err=Type.check_type("table",name,got)
  if not ok then
   return ok,err
  end
  local key_type=self.data.k
  local value_type=self.data.v
  for k,v in pairs(got) do
   local success,msg=key_type:check(connect_index(name,k).."(key)",k)
   if not success then
    return false,msg
   end
   success,msg=value_type:check(connect_index(name,k),v)
   if not success then
    return false,msg
   end
  end
  return true
 end,
 [attrs.struct]=function(self,name,got)
  local ok,err=Type.check_type("table",name,got)
  if not ok then
   return ok,err
  end
  for k in pairs(got) do
   if self.data[k]==nil then
    return false,string.format("Unexpected field %s in table %s",connect_index(name,k),name)
   end
  end
  for key,value_type in pairs(self.data) do
   local got_value=got[key]
   local success,msg=value_type:check(connect_index(name,key),got_value)
   if not success then
    return false,msg
   end
  end
  return true
 end,
 [attrs.tuple]=function(self,name,got)
  local ok,err=Type.check_type("table",name,got)
  if not ok then
   return false,err
  end
  local fixed_count=#self.data.fixed
  local vararg_type=self.data.vararg
  for i,fixed_type in ipairs(self.data.fixed) do
   local success,msg=fixed_type:check(connect_index(name,i),got[i])
   if not success then
    return false,msg
   end
  end
  if vararg_type then
   for i=fixed_count+1,#got do
    local success,msg=vararg_type:check(connect_index(name,i),got[i])
    if not success then
     return false,msg
    end
   end
  end
  return true
 end,
 [attrs.func]=function(self,name,got)
  return Type.check_type("function",name,got)
 end,
}
function Type:check(name,got)
 local check=checks[self.attr]
 if check then
  return check(self,name,got)
 end
 error("Unreachable")
end
function Type.check_type(expect,name,got)
 return Type.new(expect):check(name,got)
end
---@overload fun(attr:any):Type
---@overload fun(attr:Type.attrs,data:any):Type
function Type.new(...)
 if select("#",...)==1 then
  return Type._guess(...)
 elseif select("#",...)==2 then
  return Type._exact(...)
 end
 error("Invalid parameters",2)
end
function Type:wrap(fn)
 if self.attr~=attrs.func then
  error("wrap() can only be called on func Type",2)
 end
 return function(...)
  local args={...}
  local success,msg=self.data.args:check("function arguments",args)
  if not success then
   error(msg,2)
  end
  local results={fn(...)}
  success,msg=self.data.rets:check("function return values",results)
  if not success then
   error(msg,2)
  end
  return unpack(results)
 end
end
function Type:_and(types)
 return Type.all({self,types})
end
function Type:_or(types)
 return Type.any({self,types})
end
function Type:_not()
 return Type.non(self)
end
function Type.any(types)
 return Type._exact(attrs.any,types)
end
function Type.optional(types)
 return Type.any({"nil",types})
end
function Type.all(types)
 return Type._exact(attrs.all,types)
end
function Type.non(types)
 return Type._exact(attrs.non,types)
end
function Type.list(element_type)
 return Type._exact(attrs.list,element_type)
end
function Type.dict(key_type,value_type)
 return Type._exact(attrs.dict,{k=key_type,v=value_type})
end
function Type.struct(schema)
 return Type._exact(attrs.struct,schema)
end
function Type.custom(check_func,info)
 return Type._exact(attrs.custom,{check=check_func,info=info or "custom"})
end
function Type.tuple(fixed,vararg)
 return Type._exact(attrs.tuple,{
  fixed=fixed or {},
  vararg=vararg,
 })
end
function Type.func(args,rets)
 args=Type.new(args)
 rets=Type.new(rets)
 if args.attr~=attrs.tuple then
  args=Type.tuple({args})
 end
 if rets.attr~=attrs.tuple then
  rets=Type.tuple({rets})
 end
 return Type._exact(attrs.func,{
  args=args,
  rets=rets,
 })
end
if UnitTest then
 UnitTest:add_cases({
  {name="base_number",          expect=true, test=function() return Type.check_type("number","test",42) end},
  {name="base_number",          expect=false,test=function() return Type.check_type("number","test","42") end},
  {name="base_string",          expect=true, test=function() return Type.check_type("string","test","hello") end},
  {name="base_string",          expect=false,test=function() return Type.check_type("string","test",42) end},
  {name="base_function",        expect=true, test=function() return Type.check_type("function","test",function() end) end},
  {name="base_function",        expect=false,test=function() return Type.check_type("function","test",42) end},
  {name="base_boolean",         expect=true, test=function() return Type.check_type("boolean","test",true) end},
  {name="base_boolean",         expect=false,test=function() return Type.check_type("boolean","test",42) end},
  {name="base_nil",             expect=true, test=function() return Type.check_type("nil","test",nil) end},
  {name="base_nil",             expect=false,test=function() return Type.check_type("nil","test",42) end},
  {name="base_userdata",        expect=true, test=function() return Type.check_type("userdata","test",io.stdin) end},
  {name="base_userdata",        expect=false,test=function() return Type.check_type("userdata","test",42) end},
  {name="base_thread",          expect=true, test=function() return Type.check_type("thread","test",coroutine.create(function() end)) end},
  {name="base_thread",          expect=false,test=function() return Type.check_type("thread","test",42) end},
  {name="base_any",             expect=true, test=function() return Type.check_type("any","test",42) end},
  {name="base_true",            expect=true, test=function() return Type.check_type("true","test",true) end},
  {name="base_true",            expect=false,test=function() return Type.check_type("true","test",false) end},
  {name="base_false",           expect=true, test=function() return Type.check_type("false","test",false) end},
  {name="base_false",           expect=false,test=function() return Type.check_type("false","test",true) end},
  {name="base_integer",         expect=true, test=function() return Type.check_type("integer","test",42) end},
  {name="base_integer",         expect=false,test=function() return Type.check_type("integer","test",42.5) end},
  {name="base_decimal",         expect=true, test=function() return Type.check_type("decimal","test",42.5) end},
  {name="base_decimal",         expect=false,test=function() return Type.check_type("decimal","test",42) end},
  {name="base_nan",             expect=true, test=function() return Type.check_type("nan","test",0/0) end},
  {name="base_nan",             expect=false,test=function() return Type.check_type("nan","test",42) end},
  {name="base_truthy",          expect=true, test=function() return Type.check_type("truthy","test",42) end},
  {name="base_truthy",          expect=false,test=function() return Type.check_type("truthy","test",false) end},
  {name="base_falsy",           expect=true, test=function() return Type.check_type("falsy","test",false) end},
  {name="base_falsy",           expect=false,test=function() return Type.check_type("falsy","test",42) end},
  {name="value",                expect=true, test=function() return Type.check_type(42,"test",42) end},
  {name="value",                expect=false,test=function() return Type.check_type(42,"test",43) end},
  {name="any",                  expect=true, test=function() return Type.check_type(Type.any({"number","string"}),"test","hello") end},
  {name="any",                  expect=false,test=function() return Type.check_type(Type.any({"number","string"}),"test",true) end},
  {name="all",                  expect=true, test=function() return Type.check_type(Type.all({"integer","number"}),"test",42) end},
  {name="all",                  expect=false,test=function() return Type.check_type(Type.all({"integer","string"}),"test",42) end},
  {name="custom",               expect=true, test=function() return Type.check_type(function(x) return x>0 end,"test",42) end},
  {name="custom",               expect=false,test=function() return Type.check_type(function(x) return x>0 end,"test",-1) end},
  {name="list",                 expect=true, test=function() return Type.check_type(Type.list("number"),"test",{1,2,3}) end},
  {name="list",                 expect=false,test=function() return Type.check_type(Type.list("number"),"test",{1,"2",3}) end},
  {name="dict",                 expect=true, test=function() return Type.check_type(Type.dict("string","number"),"test",{a=1,b=2}) end},
  {name="dict",                 expect=false,test=function() return Type.check_type(Type.dict("string","number"),"test",{a=1,"2"}) end},
  {name="dict",                 expect=false,test=function() return Type.check_type(Type.dict("string","number"),"test",{a=1,b="2"}) end},
  {name="struct",               expect=true, test=function() return Type.check_type({a="number",b="string"},"test",{a=1,b="hello"}) end},
  {name="struct",               expect=false,test=function() return Type.check_type({a="number",b="string"},"test",{a=1,b=2}) end},
  {name="base_integer_negative",expect=false,test=function() return Type.check_type("integer","test",-42.5) end},
  {name="base_decimal_negative",expect=true, test=function() return Type.check_type("decimal","test",-42.5) end},
  {name="value_nil",            expect=true, test=function() return Type.check_type(nil,"test",nil) end},
  {name="value_string",         expect=true, test=function() return Type.check_type("hello","test","hello") end},
  {name="value_boolean",        expect=true, test=function() return Type.check_type(true,"test",true) end},
  {name="any_empty",            expect=false,test=function() return Type.check_type(Type.any({}),"test",nil) end},
  {name="any_empty",            expect=false,test=function() return Type.check_type(Type.any({}),"test",42) end},
  {name="all_empty",            expect=true, test=function() return Type.check_type(Type.all({}),"test",nil) end},
  {name="all_empty",            expect=true, test=function() return Type.check_type(Type.all({}),"test",42) end},
  {name="list_empty",           expect=true, test=function() return Type.check_type(Type.list("number"),"test",{}) end},
  {name="dict_empty",           expect=true, test=function() return Type.check_type(Type.dict("string","number"),"test",{}) end},
  {name="struct_empty",         expect=false,test=function() return Type.check_type({a="number"},"test",{}) end},
  {name="struct_extra_field",   expect=false,test=function() return Type.check_type({a="number"},"test",{a=1,b=2}) end},
  {name="custom_error_handling",expect=true, test=function() return Type.check_type(function(x) return x~=nil end,"test",42) end},
  {name="value_struct",         expect=true, test=function() return Type.check_type({},"test",{}) end},
  {name="value_struct",         expect=false,test=function() return Type.check_type({},"test",{a=1}) end},
  {name="any_nested",           expect=true, test=function() return Type.check_type(Type.any({"number",Type.any({"string"})}),"test","hello") end},
  {name="all_nested",           expect=false,test=function() return Type.check_type(Type.all({"number",Type.all({"string"})}),"test",42) end},
  {name="struct_nested",        expect=true, test=function() return Type.check_type({a={b="number"}},"test",{a={b=42}}) end},
  {name="struct_nested",        expect=false,test=function() return Type.check_type({a={b="number"}},"test",{a={b="42"}}) end},
  {name="list_nested",          expect=true, test=function() return Type.check_type(Type.list(Type.list("number")),"test",{{1,2},{3,4}}) end},
  {name="list_nested",          expect=false,test=function() return Type.check_type(Type.list(Type.list("number")),"test",{{1,2},{"3",4}}) end},
  {name="dict_nested",          expect=true, test=function() return Type.check_type(Type.dict("string",Type.dict("string","number")),"test",{user={age=25}}) end},
  {name="dict_nested",          expect=false,test=function() return Type.check_type(Type.dict("string",Type.dict("string","number")),"test",{user={age="25"}}) end},
  {name="tuple_fixed",          expect=true, test=function() return Type.check_type(Type.tuple({"number","string"}),"test",{42,"hello"}) end},
  {name="tuple_fixed_count",    expect=false,test=function() return Type.check_type(Type.tuple({"number","string"}),"test",{42}) end},
  {name="tuple_fixed_type",     expect=false,test=function() return Type.check_type(Type.tuple({"number","string"}),"test",{"42","hello"}) end},
  {name="tuple_vararg",         expect=true, test=function() return Type.check_type(Type.tuple({"number"},"string"),"test",{42,"a","b"}) end},
  {name="tuple_vararg_type",    expect=false,test=function() return Type.check_type(Type.tuple({"number"},"string"),"test",{42,"a",123}) end},
  {name="tuple_vararg_limit",   expect=true, test=function() return Type.check_type(Type.tuple({"number"},"string"),"test",{42,"a","b"}) end},
  {name="func",                 expect=true, test=function() return Type.check_type(Type.func("number","string"),"test",function(x) return "ok" end) end},
  {name="func",                 expect=false,test=function() return Type.check_type(Type.func("number","string"),"test",42) end},
  {
   name="func_wrap",
   expect=true,
   test=function()
    local fn=Type.func("number","string"):wrap(function(x) return tostring(x) end)
    return type(fn(42))=="string"
   end,
  },
  {
   name="func_wrap_args",
   expect=false,
   test=function()
    local fn=Type.func("number","string"):wrap(function(x) return tostring(x) end)
    return pcall(function() fn("not_number") end)
   end,
  },
  {
   name="func_wrap_rets",
   expect=false,
   test=function()
    local fn=Type.func("number","string"):wrap(function(x) return 123 end)
    return pcall(function() fn(42) end)
   end,
  },
  {name="non_base",     expect=true, test=function() return Type.check_type(Type.non("number"),"test","hello") end},
  {name="non_base",     expect=false,test=function() return Type.check_type(Type.non("number"),"test",42) end},
  {name="non_value",    expect=true, test=function() return Type.check_type(Type.non(42),"test",43) end},
  {name="non_value",    expect=false,test=function() return Type.check_type(Type.non(42),"test",42) end},
  {name="non_any",      expect=true, test=function() return Type.check_type(Type.non(Type.any({"number","string"})),"test",true) end},
  {name="non_any",      expect=false,test=function() return Type.check_type(Type.non(Type.any({"number","string"})),"test",42) end},
  {name="non_all",      expect=true, test=function() return Type.check_type(Type.non(Type.all({"integer","number"})),"test","hello") end},
  {name="non_all",      expect=false,test=function() return Type.check_type(Type.non(Type.all({"integer","number"})),"test",42) end},
  {name="non_list",     expect=true, test=function() return Type.check_type(Type.non(Type.list("number")),"test",{"a","b"}) end},
  {name="non_list",     expect=false,test=function() return Type.check_type(Type.non(Type.list("number")),"test",{1,2,3}) end},
  {name="non_struct",   expect=true, test=function() return Type.check_type(Type.non({a="number"}),"test",{a="string"}) end},
  {name="non_struct",   expect=false,test=function() return Type.check_type(Type.non({a="number"}),"test",{a=42}) end},

  {name="operator_and", expect=true, test=function() return Type.check_type(Type.new("number"):_and("integer"),"test",42) end},
  {name="operator_and1",expect=false,test=function() return Type.check_type(Type.new("number"):_and("integer"),"test",42.5) end},
  {name="operator_and2",expect=false,test=function() return Type.check_type(Type.new("number"):_and("integer"),"test","42") end},
  {name="operator_or1", expect=true, test=function() return Type.check_type(Type.new("number"):_or("string"),"test",42) end},
  {name="operator_or2", expect=true, test=function() return Type.check_type(Type.new("number"):_or("string"),"test","hello") end},
  {name="operator_or",  expect=false,test=function() return Type.check_type(Type.new("number"):_or("string"),"test",true) end},
  {name="operator_not", expect=true, test=function() return Type.check_type(Type.new("number"):_not(),"test","hello") end},
  {name="operator_not", expect=false,test=function() return Type.check_type(Type.new("number"):_not(),"test",42) end},

  {
   name="operator_complex",
   expect=true,
   test=function()
    local t=Type.new("number"):_and("integer"):_or("string")
    return t:check("test",42) and t:check("test","hello")
   end,
  },
  {name="operator_complex",expect=false,test=function() return Type.new("number"):_and("integer"):_or("string"):check("test",42.5) end},

  {name="operator_nested", expect=true, test=function() return Type.new("number"):_and(Type.new("integer"):_or("positive")):check("test",42) end},
  {name="operator_nested", expect=true, test=function() return Type.new("number"):_and(Type.new("integer"):_or("positive")):check("test",-42) end},

  {name="operator_chain",  expect=false,test=function() return Type.new("number"):_and("integer"):_and("positive"):_not():check("test",42) end},
  {name="operator_chain",  expect=true, test=function() return Type.new("number"):_and("integer"):_and("positive"):_not():check("test",-42) end},

  {name="non_with_and",    expect=true, test=function() return Type.non("string"):_and("number"):check("test",42) end},
  {name="non_with_and",    expect=false,test=function() return Type.non("string"):_and("number"):check("test","hello") end},

  {name="non_empty",       expect=false,test=function() return Type.check_type(Type.non(Type.all({})),"test",42) end},
  {name="non_empty",       expect=true, test=function() return Type.check_type(Type.non(Type.any({})),"test",42) end},

 })
end
return Type
