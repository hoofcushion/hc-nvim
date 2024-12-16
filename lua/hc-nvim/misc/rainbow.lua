local function rgb_to_colorcode(r,g,b)
 return string.format("#%02x%02x%02x",r,g,b)
end
local Util=require("hc-nvim.util")
local M={}
local function create(a,s,l,name)
 local groups={}
 for i=0,360,360/a do
  i=math.floor(i)
  local group={name.."_"..tostring(i),{fg=rgb_to_colorcode(Util.Color.hsl_to_rgb(i,s,l))}}
  table.insert(groups,group)
 end
 return Util.HLGroup.create(groups)
end
---@type table<string,HLGroup>
local HLGroups={}
function M.create(a,s,l)
 local name=string.format("Rainbow_HSL_%03d_%03d_%03d",a,s,l)
 local group=Util.tbl_check(HLGroups,name,function()
  return create(a,s,l,name):set_hl():attach()
 end)
 return group:getnames()
end
return M
