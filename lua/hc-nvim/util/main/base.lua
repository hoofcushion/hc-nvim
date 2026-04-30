---@class HC-Nvim.Util
local Util=require("hc-nvim.util.init_space")
function Util.packlen(...)
 return {n=select("#",...),...}
end
function Util.packenxtend(pack1,pack2)
 local new={n=0}
 table.move(pack1,1,pack1.n,new.n+1,new)
 new.n=new.n+pack1.n
 table.move(pack2,1,pack2.n,new.n+1,new)
 new.n=new.n+pack2.n
 return new
end
(LUAFILEDO or type)(not LUAFILE or function()
  local pack1=Util.packlen(1,2)
  local pack2=Util.packlen(4,3)
  local pack12=Util.packenxtend(pack1,pack2)
  print(Util.serialize_simple(pack12))
 end)
---@param t table
---@param s integer?
function Util.unpacklen(t,s)
 return Util.unpack(t,s or 1,t.n)
end
Util.unpack=unpack or table.unpack
---@generic T
---@param t table|fun():table
---@param ... T
---@return T
function Util.redirect(t,...)
 t=Util.eval(t)
 local n=select("#",...)
 for i=1,n do
  t[i]=select(i,...)
 end
 t.n=n
 return ...
end
function Util.empty_f() end
Util.empty_t=setmetatable({},{__index=Util.empty_f,__newindex=Util.empty_f})
function Util.serialize_simple(value)
 local t=type(value)
 if t=="string" then
  return string.format("%q",value)
 elseif t=="table" then
  local buffer={}
  buffer[1]="{"
  local i=1
  for k,v in pairs(value) do
   i=i+1
   buffer[i]="["..Util.serialize_simple(k).."]="..Util.serialize_simple(v)..","
  end
  buffer[i+1]="}"
  return table.concat(buffer)
 else
  return tostring(value)
 end
end
(LUAFILEDO or type)(not LUAFILE or function()
  print(Util.serialize_simple("1"))
 end)
local function is_name(str)
 if type(str)~="string" or #str==0 then
  return false
 end
 -- 首字符必须是字母或下划线
 local first=str:byte(1)
 if
     not (first>=0x61 and first<=0x7A) -- a-z
 and not (first>=0x41 and first<=0x5A) -- A-Z
 and first~=0x5F
 then                                  -- _
  return false
 end
 -- 后续字符必须是字母、数字或下划线
 for i=2,#str do
  local b=str:byte(i)
  if
      not (b>=0x61 and b<=0x7A) -- a-z
  and not (b>=0x41 and b<=0x5A) -- A-Z
  and not (b>=0x30 and b<=0x39) -- 0-9
  and b~=0x5F
  then                          -- _
   return false
  end
 end
 -- Lua 关键字（Lua 5.1~5.4 通用）
 local keywords={
  ["and"]=true,
  ["break"]=true,
  ["do"]=true,
  ["else"]=true,
  ["elseif"]=true,
  ["end"]=true,
  ["false"]=true,
  ["for"]=true,
  ["function"]=true,
  ["goto"]=true,
  ["if"]=true,
  ["in"]=true,
  ["local"]=true,
  ["nil"]=true,
  ["not"]=true,
  ["or"]=true,
  ["repeat"]=true,
  ["return"]=true,
  ["then"]=true,
  ["true"]=true,
  ["until"]=true,
  ["while"]=true,
  ["global"]=true, -- lua 5.5
 }
 if keywords[str] then
  return false
 end
 return true
end
function Util.serialize(value)
 local t=type(value)
 if t=="string" then
  return string.format("%q",value)
 elseif t=="table" then
  local buffer={}
  buffer[1]="{"
  local i=1
  for _,v in ipairs(value) do
   i=i+1
   buffer[i]=Util.serialize(v)..","
  end
  local max_list_key=i
  for k,v in pairs(value) do
   if not (type(k)=="number" and k>=1 and math.floor(k)==k and k<=max_list_key) then
    i=i+1
    if is_name(k) then
     buffer[i]=k.."="..Util.serialize(v)..","
    else
     buffer[i]="["..Util.serialize(k).."]="..Util.serialize(v)..","
    end
   end
  end
  -- remove comma
  if i>1 then
   buffer[i]=buffer[i]:sub(1,-2)
  end
  buffer[i+1]="}"
  return table.concat(buffer)
 else
  return tostring(value)
 end
end
(LUAFILEDO or assert)(not LUAFILE or function()
  print(Util.serialize("1"))
  print(Util.serialize({1,2,3}))
  print(Util.serialize({a=1,b=2,c=3}))
 end)
--- A Table that always return the index when indexing.
--- Useful for lua language server to find string reference.
Util.namespace=setmetatable({},{
 __index=function(t,k)
  t[k]=k
  return k
 end,
})
