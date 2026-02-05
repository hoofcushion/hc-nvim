local HCFilter=require("hc-filter.init_space")
local FilterPreset={}
function FilterPreset.grayscale_srgb()
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.grayscale_srgb(rgb)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.saturation(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.saturation(rgb,factor)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.lightness(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.lightness(rgb,factor)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.lightup(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.lightup(rgb,factor)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.lightdown(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.lightdown(rgb,factor)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.hue(shift)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.hue(rgb,shift)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.contrast(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.contrast(rgb,factor)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
function FilterPreset.invert()
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.invert(rgb)
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
local function get_symbol()
 return math.random(2)==1 and 1 or -1
end
local function random_factor_map(factor)
 return {
  -- random filter formula: 1 ± (factor) * (random number) * (srgb lightness scale [0.2126,0.7152,0.0722])
  1+get_symbol()*factor*math.random()*3*0.2126,
  1+get_symbol()*factor*math.random()*3*0.7152,
  1+get_symbol()*factor*math.random()*3*0.0722,
 }
end
-- 随机调整 rgb 的数值
function FilterPreset.random(factor)
 return function(r,g,b)
  local rgb={r,g,b}
  local ret=HCFilter.ColorFilter.map(rgb,random_factor_map(factor))
  return unpack(HCFilter.RGBFormat.rgb_to_normalize(ret))
 end
end
-- 随机调整 rgb 和 hsl 的数值
function FilterPreset.random_tune(factor)
 local hue=FilterPreset.hue(360*get_symbol()*factor*math.random()*0.33)
 local lightness=FilterPreset.lightness(1+get_symbol()*factor*math.random()*0.33)
 local saturation=FilterPreset.saturation(1+get_symbol()*factor*math.random()*0.33)
 local random=FilterPreset.random(factor)
 local list={
  random,
  hue,
  lightness,
  saturation,
 }
 return function(r,g,b)
  local v={r,g,b}
  for _,fn in ipairs(list) do
   v={fn(unpack(v))}
  end
  return unpack(v)
 end
end
return FilterPreset
