--- ---
--- A reference of a table is a fake table that correspond to key index
--- And return real value of that index, but it block all newindex.
--- ---
local Util=require("hc-nvim.util")
local Reference={}
--- return a reference table of `main`
--- example:
---```lua
--- local raw={
---  a={
---   b="c",
---  },
--- }
--- local t=Ref.create(raw)
--- t.a.b=nil
--- print(t.a.b) -- "c"
--- raw.a.b=nil
--- print(t.a.b) -- nil
---```
local function node(main,keys)
 if type(main)~="table" then
  return main
 end
 if keys==nil then
  keys={}
 end
 local nested=false
 for _,v in pairs(main) do
  if type(v)=="table" then
   nested=true
   break
  end
 end
 if not nested then
  return Util.copy(main)
 end
 return setmetatable({},{
  __index=function(_,k)
   local t=Util.tbl_get(main,keys)
   local ret=t[k]
   if type(ret)=="table" then
    local _keys=Util.deepcopy(keys)
    table.insert(_keys,k)
    return node(main,_keys)
   end
   return ret
  end,
  __newindex=Util.empty_f,
 })
end
---@generic T
---@param main T
---@return T
function Reference.create(main)
 return node(main)
end
--- Use `sup` to keep access local environment's table locals
---@generic T
---@param sup fun():T
---@return T
function Reference.get(sup)
 local mt; mt={
  __index=function(_,k)
   return sup()[k]
  end,
 }
 return node(setmetatable({},mt))
end
return Reference
