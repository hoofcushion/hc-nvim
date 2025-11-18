local function rgb_to_colorcode(r,g,b)
 return string.format("#%02x%02x%02x",r,g,b)
end
local Util=require("hc-nvim.util")
local M={}
---@param hl ConductedHighlight
local function init_rainbow(hl,a,s,l,name)
 local groups={}
 for i=0,360,360/a do
  i=math.floor(i)
  local group={name.."_"..tostring(i),{fg=rgb_to_colorcode(Util.Color.hsl_to_rgb(i,s,l))}}
  table.insert(groups,group)
 end
 hl:extend(groups)
 return hl
end
---@type table<string,ConductedHighlight>
local Highlights={}
function M.create(a,s,l)
 local name=string.format("Rainbow_HSL_%03d_%03d_%03d",a,s,l)
 local hl=Highlights[name]
 if not hl then
  hl=Util.ConductedHighlight.new()
  init_rainbow(hl,a,s,l,name)
  hl:attach()
  Highlights[name]=hl
 end
 local names={}
 for _,v in ipairs(hl.highlights) do
  table.insert(names,v[1])
 end
 return names
end
return M
