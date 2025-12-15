local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
local Loader=require("lazy.core.loader")
local Plugin=require("lazy.core.plugin")
local Mappings=require("hc-nvim.setup.mapping")
local preset_modmap=Util.create_modmap("hc-nvim.config.preset")
---@type table<string,(LazyPluginSpec|{base:LazyPluginSpec,keyimp:table,after:function,hook:{[1]:string[],[2]:function}[]})>
local PluginPresets=Util.Cache.table(function(name)
 local fields=preset_modmap[name]
 if not fields then
  return Util.empty_t
 end
 return Util.Cache.table(function(field)
  if fields[field] then
   return loadfile(fields[field])()
  end
 end)
end)
local Hook={}
local event_to_hook_set={}
local function strong_remove(parent,keys,ck)
 for _,key in ipairs(keys) do
  local child=parent[key]
  child[ck]=nil
  if next(child)==nil then
   parent[key]=nil
  end
 end
end
local function strong_set(parent,keys,ck)
 for _,key in ipairs(keys) do
  local child=parent[key]
  if child==nil then
   child={}
   parent[key]=child
  end
  child[ck]=true
 end
end
local hook_to_status={}
function Hook.add(hook)
 local hook_status={}
 hook_to_status[hook]=hook_status
 for _,event in ipairs(hook[1]) do
  hook_status[event]=true
 end
 strong_set(event_to_hook_set,hook[1],hook)
end
function Hook.check(event)
 local hook_set=event_to_hook_set[event]
 if not hook_set then
  return
 end
 for hook in pairs(hook_set) do
  local status=hook_to_status[hook]
  if status then
   status[event]=nil
  end
  if not next(status) then
   hook_to_status[hook]=nil
   strong_remove(event_to_hook_set,hook[1],hook)
   hook[2]()
  end
 end
end
--- hooked lazy plugin field
local PresetGetter={
 keys=function(plugin,field,value,preset,name)
  ---@diagnostic disable-next-line: missing-fields
  value=Plugin._values(plugin,{[field]=value},field,false)
  Mappings:export(name):lazykeys(value)
  if value~=nil and next(value)~=nil then
   return value
  end
 end,
 event=function(plugin,field,value,preset,name)
  ---@diagnostic disable-next-line: missing-fields
  value=Plugin._values(plugin,{[field]=value},field,false)
  value=Util.Event.events_normalize(value) or {}
  if value~=nil and next(value)~=nil then
   return value
  end
 end,
 cmd=function(plugin,field,value,preset,name)
  return value
 end,
 opts=function(plugin,field,value,preset,name)
  ---@diagnostic disable-next-line: missing-fields
  value=Plugin._values(plugin,{[field]=value},field,false)
  Mappings:export(name):configure(value)
  if value~=nil and next(value)~=nil then
   return value
  end
 end,
 config=function(plugin,field,value,preset,name)
  if plugin.config or plugin.opts then
   Hook.check(plugin.name,plugin)
   Loader.config(plugin)
  end
  if preset.keyimp then
   local specs=Util.eval(preset.keyimp,plugin)
   if specs~=nil then
    Mappings.forspecs(specs,function(mapspec)
     Mappings:add(mapspec):create()
    end)
   end
  end
  if preset.after then
   Util.eval(preset.after,plugin)
  end
 end,
}
-- local priority=2^10
local Preset={}
function Preset.apply(specs)
 return Util.Lazy.foreach(specs,function(spec)
  -- get preset
  local name=Util.Lazy.getname(spec)
  local modname=Util.Lazy.normname(name)
  local preset=PluginPresets[modname]
  local base=preset.base
  if base and type(base)=="table" then
   for k,v in pairs(base) do
    spec[k]=v
   end
  end
  if Config.platform.vscode and spec.vscode==false then
   spec.enabled=false
   return
  end
  -- set hooked getter
  for field,getter in pairs(PresetGetter) do
   local orig=spec[field]
   spec[field]=function(plugin)
    local value=orig or preset[field]
    Util.deepset(plugin,field,value)
    local ret=getter(plugin,field,value,preset,modname)
    Util.deepset(plugin,field,ret)
    return ret
   end
  end
  if preset.hook then
   Hook.add(preset.hook)
  end
  -- equalize dependencies
  if spec.dependencies~=nil then
   spec={spec,spec.dependencies}
   spec.dependencies=nil
  end
  -- -- add priority
  -- if spec.priority==nil then
  --  spec.priority=priority
  --  priority=priority-1
  -- end
  --  if spec.auto==true then
  --   spec.lazy=vim.fn.argc()==0
  --  end
 end)
end
return Preset
