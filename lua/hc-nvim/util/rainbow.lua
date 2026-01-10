local Util=require("hc-nvim.util")
local M={}
local function init_rainbow_hl(name,layer,saturation,lightness)
 local groups={}
 local i,e,s=0,360,360/layer
 while i<e do
  local rgb=Util.ColorFormat.hsl_to_rgb({math.floor(i),saturation,lightness})
  local fg=Util.RGBFormat.rgb_to_hex(rgb)
  local group={
   name.."_"..tostring(math.floor(i)),
   {fg=fg},
  }
  table.insert(groups,group)
  i=i+s
 end
 return groups
end
---@type table<string,ConductedHighlight>
local Highlights={}
function M.create(layer,saturation,lightness)
 assert(saturation<1)
 assert(lightness<1)
 local name=string.format("Rainbow_HSL_%f_%f_%f",layer,saturation,lightness)
 local hl=Highlights[name]
 if not hl then
  hl=Util.ConductedHighlight.new()
  hl:extend(init_rainbow_hl(name,layer,saturation,lightness))
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
