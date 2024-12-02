---@param p number
---@param q number
---@param h number
local function hue_to_rgb(p,q,h)
 if h<0 then h=h+1; elseif -h<-1 then h=h-1; end
 if h<1/6 then return p+(q-p)*6*h; end
 if h<1/2 then return q; end
 if h<2/3 then return p+(q-p)*(2/3-h)*6; end
 return p
end
---@param h number
---@param s number
---@param l number
---@return integer,integer,integer rgb_code
local function hsl_to_rgb(h,s,l)
 l=l/100
 if s==0 then
  l=math.floor(l*255)
  return l,l,l
 end
 h,s=h/360,s/100
 local q=l<0.5 and l*(1+s) or l+s-l*s
 local p=2*l-q
 local r,g,b=hue_to_rgb(p,q,h+1/3),hue_to_rgb(p,q,h),hue_to_rgb(p,q,h-1/3)
 return math.floor(r*255),math.floor(g*255),math.floor(b*255)
end
local function rgb_to_colorcode(r,g,b)
 return string.format("#%02x%02x%02x",r,g,b)
end
local Util=require("hc-nvim.util")
local M={}
local function create(a,s,l,name)
 local groups={}
 for i=0,360,360/a do
  i=math.floor(i)
  local group={name.."_"..tostring(i),{fg=rgb_to_colorcode(hsl_to_rgb(i,s,l))}}
  table.insert(groups,group)
 end
 return Util.HLGroup.create(groups)
end
---@type table<string,HLGroup>
local HLGroups={}
function M.create(a,s,l)
 local name=string.format("Rainbow_HSL_%03d_%03d_%03d",a,s,l)
 local group=Util.tbl_echeck(HLGroups,name,function()
  return create(a,s,l,name):set_hl():attach()
 end)
 return group:getnames()
end
return M
