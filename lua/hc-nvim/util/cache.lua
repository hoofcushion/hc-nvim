local Util=require("hc-nvim.util.init_space")
local IS_RET=setmetatable({},{__tostring="Ret"})
---@class Cache
local Cache={}
--- fancy function cache, supports:
---  * special index
---  * multiple index
---  * multiple return values
---@generic T:function
---@param fn T
---@return T
function Cache.create(fn)
 local cache={}
 local function retf(...)
  local c=cache
  for i=1,select("#",...) do
   c=Util.pindex(c,select(i,...))
  end
  local ret=c[IS_RET]
  if ret==nil then
   ret=Util.packlen(fn(...))
   c[IS_RET]=ret
  end
  if ret.n==1 then
   return ret[1]
  end
  return Util.unpacklen(ret)
 end
 return retf
end
--- simple function cache
--- only as backend of cached table
---@generic T:function
---@param fn T
---@return T
function Cache.create_simple(fn)
 local cache={}
 local function retf(k)
  if cache[k]==nil then
   cache[k]=fn(k)
  end
  return cache[k]
 end
 return retf
end
---@generic K,V
---@param fn fun(K):V?
---@return table<K,V>
function Cache.table(fn)
 fn=Cache.create_simple(fn)
 return setmetatable({},{
  __index=function(_,K)
   return fn(K)
  end,
 })
end
return Cache
