local Util=require("hc-nvim.util")
---@class TSProxy
---@operator call:TSNode?
---@operator concat:TSProxy
---@field [integer] TSProxy
---@field [string] TSProxy
---@field [PRIVATE] TSProxy.private
local TSProxy={}
---@class PRIVATE
local PRIVATE={}
-- dereference
function TSProxy:__call()
 local private=self[PRIVATE]
 return private.node
end
-- print
function TSProxy:__tostring()
 local private=self[PRIVATE]
 local node=private.node
 if not node then
  return "nil"
 end
 local result={}
 local index=0
 for child,field in node:iter_children() do
  index=index+1
  local field_str=field or "anonymous"
  local type_str=child:type()
  table.insert(result,string.format("[%2d] %-12s %s",index,field_str,type_str))
 end
 return node:type()..": {\n  "..table.concat(result,"\n  ").."\n}"
end
local function init_children(node)
 if not node then
  return
 end
 local ret={}
 local field_count,type_count={},{}
 local index=0
 for child,field in node:iter_children() do
  index=index+1
  ret[index]=child
  -- field key
  field=field or "anonymous"
  local fcount=(field_count[field] or 0)+1
  field_count[field]=fcount
  if fcount==1 then ret[field]=child end
  ret[field.."_"..tostring(fcount)]=child
  -- type key
  local child_type=child:type()
  local tcount=(type_count[child_type] or 0)+1
  type_count[child_type]=tcount
  if tcount==1 then ret[child_type]=child end
  ret[child_type.."_"..tostring(tcount)]=child
 end
 return ret
end
-- child proxy
function TSProxy:__index(k)
 local private=self[PRIVATE]
 local children=private.children
 if children[k] then
  return TSProxy.new(children[k])
 end
 return TSProxy.new()
end
---@param node TSNode?
---@return TSProxy
function TSProxy.new(node)
 ---@class TSProxy.private
 local private={}
 private.node=node
 ---@type table<any,TSNode>
 private.children=Util.lazy(
  function() return init_children(node) or {} end,
  function(t) private.children=t end
 )
 return setmetatable(
  {[PRIVATE]=private},
  TSProxy
 )
end
return TSProxy
