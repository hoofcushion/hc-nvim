local M=require("hc-filter.init_space")
---@class ColorFilter
local ColorFilter={}
ColorFilter.grayscale_ntsc=function(rgb)
 local gray=math.floor(rgb[1]*0.299+rgb[2]*0.587+rgb[3]*0.114+0.5)
 return {gray,gray,gray}
end
ColorFilter.grayscale_srgb=function(rgb)
 local gray=math.floor(rgb[1]*0.2126+rgb[2]*0.7152+rgb[3]*0.0722+0.5)
 return {gray,gray,gray}
end
ColorFilter.saturation=function(rgb,factor)
 local hsl=M.ColorFormat.rgb_to_hsl(rgb)
 hsl[2]=hsl[2]*factor
 if hsl[2]>1 then hsl[2]=1 end
 if hsl[2]<0 then hsl[2]=0 end
 return M.ColorFormat.hsl_to_rgb(hsl)
end
ColorFilter.brightness=function(rgb,delta)
 local hsl=M.ColorFormat.rgb_to_hsl(rgb)
 hsl[3]=hsl[3]+delta
 if hsl[3]>1 then hsl[3]=1 end
 if hsl[3]<0 then hsl[3]=0 end
 return M.ColorFormat.hsl_to_rgb(hsl)
end
ColorFilter.hue=function(rgb,shift)
 local hsl=M.ColorFormat.rgb_to_hsl(rgb)
 hsl[1]=(hsl[1]+shift)%360
 if hsl[1]<0 then hsl[1]=hsl[1]+360 end
 return M.ColorFormat.hsl_to_rgb(hsl)
end
ColorFilter.contrast=function(rgb,factor)
 local result={}
 for i=1,3 do
  local value=(rgb[i]/255-0.5)*factor+0.5
  value=value*255
  if value<0 then value=0 end
  if value>255 then value=255 end
  result[i]=math.floor(value+0.5)
 end
 return result
end
ColorFilter.invert=function(rgb)
 return {255-rgb[1],255-rgb[2],255-rgb[3]}
end
return ColorFilter
