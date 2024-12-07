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
---@generic T
---@param main T
---@return T
function Reference.create(main,keys)
 if type(main)~="table" then
  return main
 end
 local nested=false
 for _,v in pairs(main) do
  if type(v)=="table" then
   nested=true
   break
  end
 end
 if not nested then
  return vim.deepcopy(main)
 end
 if keys==nil then
  keys={}
 end
 return setmetatable({},{
  __index=function(_,k)
   local ret=Util.tbl_get(main,keys)[k]
   if type(ret)=="table" then
    local _keys=Util.deepcopy(keys)
    table.insert(_keys,k)
    return Reference.create(main,_keys)
   end
   return ret
  end,
  __newindex=Util.empty_f,
 })
end
return Reference
