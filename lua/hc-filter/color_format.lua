---@class ColorFormat
local ColorFormat={}
ColorFormat.rgb_to_hsl=function(rgb)
 local r,g,b=rgb[1]/255,rgb[2]/255,rgb[3]/255
 local max,min=math.max(r,g,b),math.min(r,g,b)
 local h,s,l=0,0,0
 l=(max+min)/2
 if max==min then
  s=0
 else
  if l<=0.5 then
   s=(max-min)/(max+min)
  else
   s=(max-min)/(2-max-min)
  end
 end
 if max==min then
  h=0
 else
  if max==r then
   h=(g-b)/(max-min)
   if g<b then
    h=h+6
   end
  elseif max==g then
   h=2+(b-r)/(max-min)
  else
   h=4+(r-g)/(max-min)
  end
  h=h*60
 end
 h=h%360
 return {h,s,l}
end
local function hue_to_rgb(p,q,t)
 if t<0 then t=t+1 end
 if t>1 then t=t-1 end
 if t<1/6 then return p+(q-p)*6*t end
 if t<1/2 then return q end
 if t<2/3 then return p+(q-p)*(2/3-t)*6 end
 return p
end

ColorFormat.hsl_to_rgb=function(hsl)
 local h,s,l=hsl[1],hsl[2],hsl[3]
 if s==0 then
  local v=math.floor(l*255+0.5)
  return {v,v,v}
 end
 local q
 if l<0.5 then
  q=l*(1+s)
 else
  q=l+s-l*s
 end
 local p=2*l-q
 local h_k=h/360
 local t_r=h_k+1/3
 local t_g=h_k
 local t_b=h_k-1/3
 local r=math.floor(hue_to_rgb(p,q,t_r)*255+0.5)
 local g=math.floor(hue_to_rgb(p,q,t_g)*255+0.5)
 local b=math.floor(hue_to_rgb(p,q,t_b)*255+0.5)
 return {r,g,b}
end
return ColorFormat
