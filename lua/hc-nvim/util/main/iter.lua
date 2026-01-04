---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
--- Iterate the value itself, and stop.
local function self_iter(any,done)
 if done==nil then
  return true,any
 end
end
---@generic T: any, K, V
---@param any T
---@return fun(table: table<K, V>, index?: K):K, V
---@return T?
function Util.ppairs(any)
 if any==nil then
  return Util.empty_f
 end
 if type(any)=="table" then
  return pairs(any)
 end
 return self_iter,any
end
---@generic T: any, V
---@param any T
---@return fun(any:V[],i?:integer):integer,V
---@return T?
---@return integer?
function Util.pipairs(any)
 if any==nil then
  return Util.empty_f
 end
 if type(any)=="table" then
  return ipairs(any)
 end
 return self_iter,any
end
---@generic K,V
---@param s {[1]:table<K,V>,[2]:K[]}
---@return K?,V?
local function range_iter(s)
 local t=s[1]
 local r=s[2]
 for i=s[3],s[4] do
  local k=r[i]
  local v=t[k]
  if v~=nil then
   s[3]=i+1
   return k,v
  end
 end
end
---@generic K, V
---@param tbl table<K,V>
---@param range K[]
---@return fun(t:{[1]:table<K,V>,[2]:any[],[3]:integer}):K,V
---@return {[1]:table<K,V>,[2]:any[]}
function Util.rpairs(tbl,range)
 return range_iter,{tbl,range,1,#range}
end
