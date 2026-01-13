---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
function Util.packlen(...)
 return {n=select("#",...),...}
end
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
function Util.batch(fn,...)
 for i=1,select("#",...) do
  local ret=fn(select(i,...))
  if ret then return ret end
 end
end
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
   buffer[i]="["..Util.serialize(k).."]="..Util.serialize(v)..","
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
   if not (type(k)=="number"
    and k>=1
    and math.floor(k)==k
    and k<=max_list_key)
   then
    i=i+1
    buffer[i]="["..Util.serialize(k).."]="..Util.serialize(v)..","
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
