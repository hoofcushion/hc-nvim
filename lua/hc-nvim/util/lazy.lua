local Util=require("hc-nvim.util")
local Lazy={}
local trimmed={
 [".lua"]=true,
 [".nvim"]=true,
}
---@param name string
function Lazy.normname(name)
 local _,e=Util.rfind(name,"/",nil,true)
 if e then
  name=name:sub(e+1)
 end
 local _,e=Util.rfind(name,".",nil,true)
 if e~=nil and trimmed[name:sub(e)] then
  name=name:sub(1,e-1)
 end
 if name:find(".",1,true) then
  name=name:gsub("%.","-")
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
---@generic T
---@param spec T|LazySpec
---@param fn fun(spec:T)
---@return LazySpec
function Lazy.foreach(spec,fn)
 if type(spec)=="string" then
  spec={spec}
 end
 if (#spec>1 or type(spec[1])=="table") and Util.is_list(spec) then
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
