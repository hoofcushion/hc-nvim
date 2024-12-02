local Util=require("hc-nvim.util")
---@enum (key) Valitab.attrs
local valid_attrs={
 dict=true,
 enum=true,
 func=true,
 list=true,
 recur=true,
 type=true,
 union=true,
}
local attrs_needs_tbl_input={
 dict=true,
 list=true,
 recur=true,
}
---@alias Valitab.type type|Valitab.special_type
---@enum (key) Valitab.special_type
local special={
 integer=function(val)
  return type(val)=="number" and math.floor(val)==val
 end,
 float=function(val)
  return type(val)=="number" and math.floor(val)~=val
 end,
 ["true"]=function(val)
  return val==true
 end,
 ["false"]=function(val)
  return val==false
 end,
 any=function()
  return true
 end,
}
---@alias Valitab.data.dict  {k:ValitabSpec,v:ValitabSpec}
---@alias Valitab.data.enum  table<any,true>
---@alias Valitab.data.func  fun(x):boolean,string
---@alias Valitab.data.list  ValitabSpec
---@alias Valitab.data.recur table<any,ValitabSpec>
---@alias Valitab.data.type  any
---@alias Valitab.data.union Valitab.type[]
---@alias Valitab.data.tbl
---| Valitab.data.dict
---| Valitab.data.list
---| Valitab.data.recur
---@alias Valitab.data
---| Valitab
---| Valitab.data.tbl
---| Valitab.data.enum
---| Valitab.data.func
---| Valitab.data.type
---| Valitab.data.union
---@alias ValitabSpec {attr:Valitab.attrs,data:Valitab.data}|string
---@class Valitab
---@field data Valitab.data
---@field attr Valitab.attrs
---@field name string
local Valitab={
 name="?",
 as_key=false,
 keys={},
}
--- new({attr="dict",data={k=vtype,v=vtype}})
--- new({attr="enum",data={"a",true,1}})
--- new({attr="func",data=function(x) return type(x)=="number" end})
--- new({attr="list",data={vtype}})
--- new({attr="recur",data={k=vtype,v=vtype}})
--- new({attr="union",data={vtype}})
---@param opts ValitabSpec
function Valitab.new(name,opts)
 local obj=Util.Class.new(Valitab)
 obj.name=name
 if type(opts)=="string" then
  obj.attr="type"
  obj.data=opts
 elseif type(opts)=="table" then
  if opts.data and opts.attr then
   obj.data=opts.data
   obj.attr=opts.attr
  else
   obj.data=opts
   obj.attr="recur"
  end
 end
 return obj
end
local function index_connect(keys)
 local ret={}
 for _,k in ipairs(keys) do
  if type(k)=="string" then
   if string.find(k,"^[_A-Za-z][_A-Za-z0-9]*$") then
    table.insert(ret,"."..k)
   else
    table.insert(ret,'["'..k..'"]')
   end
  else
   table.insert(ret,"["..tostring(k).."]")
  end
 end
 return table.concat(ret)
end
---@param key any
---@param as_key boolean
---@param spec ValitabSpec
function Valitab:index(key,as_key,spec)
 local obj=Valitab.new(self.name,spec)
 obj.keys=vim.deepcopy(self.keys)
 table.insert(obj.keys,key)
 obj.as_key=as_key
 return obj
end
---@param any any
---@return string
local function qtostring(any)
 return string.format("%q",tostring(any))
end
function Valitab:getname()
 local name=self.name
 if next(self.keys)~=nil then
  name=name..index_connect(self.keys)
  if self.as_key then
   name=name.." (key)"
  else
   name=name.." (value)"
  end
 end
 return name
end
function Valitab:msg(got)
 return [[Type error: ]]..self:getname()
  ..[[, expect ]]..self:tostring()
  ..[[, got ]]..qtostring(got)
end
function Valitab:tostring()
 local attr=self.attr
 local data=self.data
 if attr=="type" then
  return data
 elseif attr=="union" then
  local ret={}
  for _,v in ipairs(data) do
   if type(v)=="string" then
    table.insert(ret,v)
   else
    table.insert(ret,"...others")
    break
   end
  end
  return "["..table.concat(ret,",").."]"
 elseif attr=="enum" then
  local ret={}
  for k in pairs(data) do
   if type(k)=="string" then
    table.insert(ret,qtostring(k))
   else
    table.insert(ret,"...others")
    break
   end
  end
  return "["..table.concat(ret,",").."]"
 end
 return "?"
end
function Valitab:type(value)
 local data=self.data
 local ok=true
 local special_check=special[data]
 if special_check~=nil then
  ok=special_check(value)
 else
  ok=type(value)==data
 end
 if ok then
  return true
 end
 return false,self:msg(value)
end
function Valitab:union(value)
 ---@type Valitab.data.union
 local data=self.data
 local ok,err
 for _,v in ipairs(data) do
  ok,err=Valitab.validate(self.name,value,v)
  if ok then
   return true
  end
 end
 return false,err
end
function Valitab:enum(value)
 ---@type Valitab.data.enum
 local data=self.data
 if data[value]~=nil then
  return true
 end
 return false,self:msg(value)
end
function Valitab:list(value)
 ---@type Valitab.data.list
 local data=self.data
 for i,v in ipairs(value) do
  local ok,err=self:index(i,true,data):check(v)
  if not ok then
   return false,err
  end
 end
 return true
end
function Valitab:dict(value)
 ---@type Valitab.data.dict
 local data=self.data
 local ktype=data.k
 local vtype=data.v
 for k,v in pairs(value) do
  local ok,err=self:index(k,true,ktype):check(k)
  if not ok then return false,err end
  ok,err=self:index(k,false,vtype):check(v)
  if not ok then return false,err end
 end
 return true
end
function Valitab:recur(value)
 ---@type Valitab.data.recur
 local data=self.data
 for k,v in pairs(data) do
  local ok,err=self:index(k,true,v):check(value[k])
  if not ok then return false,err end
 end
 return true
end
function Valitab:check(value)
 local attr=self.attr
 if not valid_attrs[attr] then
  return false,"attr not valid"
 end
 if attrs_needs_tbl_input[attr] and type(value)~="table" then
  return false,"value type not match the attr"
 end
 return self[attr](self,value)
end
function Valitab:assert(value)
 local ok,err=self:check(value)
 if not ok then
  error(err)
 end
end
function Valitab.validate(name,val,spec)
 return Valitab.new(name,spec):check(val)
end
function Valitab.validate_assert(name,val,spec)
 return Valitab.new(name,spec):assert(val)
end
function Valitab.mk(attr,data)
 return {attr=attr,data=data}
end
function Valitab.mklist(element)
 return Valitab.mk("list",element)
end
function Valitab.mkdict(ktype,vtype)
 return Valitab.mk("dict",{k=ktype,v=vtype})
end
function Valitab.mkunion(...)
 return Valitab.mk("union",{...})
end
function Valitab.mkenum(...)
 return Valitab.mk("enum",Util.tbl_to_set({...}))
end
function Valitab.mkoptional(...)
 return Valitab.mkunion("nil",...)
end
if TEST then
 local V={
  any=nil,
  _nil=nil,
  _nan=0/0,
  _true=true,
  _false=false,
  _function=function() end,
  integer=1,
  float=0.1,
  number=math.pi,
  string="hello",
  table={},
  thread=coroutine.create(function() end),
  userdata=vim.NIL,
 }
 local specs={
  --- special types
  {spec={data="any",attr="type"},                        value=V.any,               expect=true},
  {spec={data="true",attr="type"},                       value=V._true,             expect=true},
  {spec={data="false",attr="type"},                      value=V._false,            expect=true},
  {spec={data="float",attr="type"},                      value=V.float,             expect=true},
  {spec={data="integer",attr="type"},                    value=V.integer,           expect=true},
  --- special types negative
  {spec={data="true",attr="type"},                       value=V._false,            expect=false},
  {spec={data="false",attr="type"},                      value=V._true,             expect=false},
  {spec={data="float",attr="type"},                      value=V.integer,           expect=false},
  {spec={data="integer",attr="type"},                    value=V.float,             expect=false},
  --- types
  {spec={data="boolean",attr="type"},                    value=V._true,             expect=true},
  {spec={data="function",attr="type"},                   value=V._function,         expect=true},
  {spec={data="nil",attr="type"},                        value=V._nil,              expect=true},
  {spec={data="number",attr="type"},                     value=V.number,            expect=true},
  {spec={data="string",attr="type"},                     value=V.string,            expect=true},
  {spec={data="table",attr="type"},                      value=V.table,             expect=true},
  {spec={data="thread",attr="type"},                     value=V.thread,            expect=true},
  {spec={data="userdata",attr="type"},                   value=vim.NIL,             expect=true},
  --- types negative
  {spec={data="boolean",attr="type"},                    value=V._nil,              expect=false},
  {spec={data="function",attr="type"},                   value=V._nil,              expect=false},
  {spec={data="nil",attr="type"},                        value=V._nan,              expect=false},
  {spec={data="number",attr="type"},                     value=V._nil,              expect=false},
  {spec={data="string",attr="type"},                     value=V._nil,              expect=false},
  {spec={data="table",attr="type"},                      value=V._nil,              expect=false},
  {spec={data="thread",attr="type"},                     value=V._nil,              expect=false},
  {spec={data="userdata",attr="type"},                   value=V._nil,              expect=false},
  --- enums
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value="a",                 expect=true},
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value=true,                expect=true},
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value=1,                   expect=true},
  --- enums negative
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value="b",                 expect=false},
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value=false,               expect=false},
  {spec={data={a=true,[true]=true,[1]=true},attr="enum"},value=2,                   expect=false},
  --- unions
  {spec={data={"string","number"},attr="union"},         value=V.string,            expect=true},
  {spec={data={"string","number"},attr="union"},         value=V.number,            expect=true},
  --- unions negative
  {spec={data={"string","number"},attr="union"},         value=V._function,         expect=false},
  --- lists
  {spec={data="string",attr="list"},                     value={V.string},          expect=true},
  {spec={data="string",attr="list"},                     value={V.string,V.string}, expect=true},
  {spec={data="integer",attr="list"},                    value={V.integer},         expect=true},
  --- lists negative
  {spec={data="string",attr="list"},                     value={V.integer},         expect=false},
  {spec={data="string",attr="list"},                     value={V.string,V.integer},expect=false},
  {spec={data="integer",attr="list"},                    value={V.string},          expect=false},
  --- dicts
  {spec={data={k="string",v="integer"},attr="dict"},     value={a=1,b=2},           expect=true},
  {spec={data={k="integer",v="integer"},attr="dict"},    value={[1]=2,[2]=3},       expect=true},
  --- dicts negative
  {spec={data={k="string",v="integer"},attr="dict"},     value={[1]=2,[2]=3},       expect=false},
  {spec={data={k="integer",v="integer"},attr="dict"},    value={a=1,b=2},           expect=false},
  -- recur
  {
   spec={
    a="integer",
    b={
     c="string",
    },
   },
   value={
    a=V.integer,
    b={
     c=V.string,
    },
   },
   expect=true,
  },
  -- recur negative
  {
   spec={
    a="integer",
    b={
     c="string",
    },
   },
   value={
    a=V.string,
    b={
     c=V.integer,
    },
   },
   expect=false,
  },
 }
 for _,v in ipairs(specs) do
  local spec,value,expect=v.spec,v.value,v.expect
  local ok,err=Valitab.validate("test",value,spec)
  if ok~=expect then
   vim.print(v,err)
  end
 end
end
return Valitab
