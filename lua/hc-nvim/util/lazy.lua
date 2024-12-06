local Util=require("hc-nvim.util")
local Lazy={}
---@param name string
function Lazy.normname(name)
 local _,e=Util.rfind(name,"/",nil,true)
 if e then
  name=name:sub(e+1)
 end
 if Util.startswith(name,"mini.") then
  name="mini-"..Util.trimprefix(name,"mini.")
 end
 local _,e=Util.rfind(name,".",nil,true)
 if e then
  name=name:sub(1,e-1)
 end
 return name
end
---@param spec table
function Lazy.getname(spec)
 return spec.name
  or spec[1]
  or spec.dir
  or spec.url
end
Lazy.normname=Util.Cache.create(Lazy.normname)
Lazy.getname=Util.Cache.create(Lazy.getname)
---@param spec LazySpec
---@param fn fun(spec:LazyPluginSpec)
---@return LazySpec
function Lazy.foreach(spec,fn)
 if type(spec)=="string" then
  return Lazy.foreach({spec},fn)
 elseif #spec>1 and Util.is_list(spec) then
  for i,v in ipairs(spec) do
   spec[i]=Lazy.foreach(v,fn)
  end
  return spec
 elseif Lazy.getname(spec) then
  return fn(spec) or spec
 elseif spec.import~=nil then
  return spec
 end
 return spec
end
return Lazy
