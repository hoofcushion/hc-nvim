local function index_keys(tbl,keys)
 local aux=tbl
 for _,v in ipairs(keys) do
  aux=aux[v]
 end
 return aux
end
local function copy(tbl)
 local ret={}
 for k,v in pairs(tbl) do
  ret[k]=v
 end
 return ret
end
local function empty() end
local Ref={}
--- return a new table that track index, and do all the index again
--- so if the original table is changed, the new table will not need update
---@generic T
---@param main T
---@return T
function Ref.create(main,keys)
 if type(main)~="table" then
  return main
 end
 local no_tbl=true
 for _,v in pairs(main) do
  if type(v)=="table" then
   no_tbl=false
   break
  end
 end
 if no_tbl then
  return main
 end
 if keys==nil then keys={} end
 local mem={}
 return setmetatable(copy(main),{
  __index=function(_,k)
   local ret=mem[k]
   if ret==nil then
    ret=index_keys(main,keys)[k]
    mem[k]=ret
   end
   return copy(ret)
  end,
  __newindex=empty,
 })
end
return Ref
