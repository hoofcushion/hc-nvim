local IS_NIL=setmetatable({},{__tostring="Nil"})
local IS_NAN=setmetatable({},{__tostring="NaN"})
local IS_RET=setmetatable({},{__tostring="Ret"})
local function pindex(t,k)
 if k==nil then
  k=IS_NIL
 elseif k~=k then
  k=IS_NAN
 end
 local ret=t[k]
 if ret==nil then
  ret={}
  t[k]=ret
 end
 return ret
end
local Cache={}
---@generic T:function
---@param fn T
---@return T
function Cache.create(fn)
 local cache={}
 local function retf(...)
  local c=cache
  for i=1,select("#",...) do
   c=pindex(c,select(i,...))
  end
  local ret=c[IS_RET]
  if ret==nil then
   ret=vim.F.pack_len(fn(...))
   c[IS_RET]=ret
  end
  if ret.n==1 then
   return ret[1]
  end
  return vim.F.unpack_len(ret)
 end
 return retf
end
---@generic K,V
---@param fn fun(K):V?
---@return table<K,V>
function Cache.table(fn)
 return setmetatable({},{
  __index=Cache.create(function(_,K)
   local R=fn(K)
   return R
  end),
 })
end
return Cache
