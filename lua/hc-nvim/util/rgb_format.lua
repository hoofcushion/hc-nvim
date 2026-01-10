local bit=require("bit")
---@class RGBFmt
local RGBFormat={rgb={},hex={},num={}}
RGBFormat.hex_to_rgb=function(hex)
 local n=tonumber(hex:sub(2),16)
 return {
  bit.rshift(bit.band(n,0xFF0000),16),
  bit.rshift(bit.band(n,0x00FF00),8),
  bit.band(n,0x0000FF),
 }
end
RGBFormat.num_to_rgb=function(n)
 return {
  bit.rshift(bit.band(n,0xFF0000),16),
  bit.rshift(bit.band(n,0x00FF00),8),
  bit.band(n,0x0000FF),
 }
end
RGBFormat.rgb_to_hex=function(rgb)
 return string.format("#%02x%02x%02x",rgb[1],rgb[2],rgb[3])
end
RGBFormat.rgb_to_num=function(rgb)
 return bit.bor(bit.lshift(rgb[1],16),
  bit.lshift(rgb[2],8),
  rgb[3])
end
local function clamp(v,min,max)
 if v<min then
  return min
 elseif v>max then
  return max
 else
  return v
 end
end
RGBFormat.rgb_to_normalize=function(rgb)
 return {
  clamp(rgb[1],0,255),
  clamp(rgb[2],0,255),
  clamp(rgb[3],0,255),
 }
end
return RGBFormat
