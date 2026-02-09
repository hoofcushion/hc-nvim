local HCNvim=require("hc-nvim.init_space")
local Config=HCNvim.Config
local Util=HCNvim.Util
--- ---
--- load dependencies
--- ---
local Loader=require("lazy.core.loader")
local Plugin=require("lazy.core.plugin")
--- ---
--- initialize keymap interface
--- ---
local Interface=require("hc-nvim.setup.mapping").Interface
if not Interface then
 Interface=Util.Interface.new()
end
--- ---
--- Hook module
--- ---
if false then
 ---@class hook
 local hook={
  [1]=nil, ---@type string[]
  [2]=nil, ---@type function
 }
end
local Hook={}
local rg=Util.RelationGraph.new()
---@param hooks hook[]
function Hook.add(hooks)
 for _,hook in ipairs(hooks) do
  rg:extend_k(hook[2],hook[1])
 end
end
function Hook.check(event)
 local callbacks=rg:del_k(event)
 if callbacks then
  for _,callback in ipairs(callbacks) do
   callback()
  end
 end
end
--- ---
--- hooked preset loader
--- ---
local PresetGetter={
 keys=function(plugin,field,value,preset,name)
  ---@diagnostic disable-next-line: missing-fields
  value=Plugin._values(plugin,{[field]=value},field,false)
  Interface:export(name):lazykeys(value)
  if value~=nil and next(value)~=nil then
   return value
  end
 end,
 event=function(plugin,field,value,preset,name)
  ---@diagnostic disable-next-line: missing-fields
  value=Plugin._values(plugin,{[field]=value},field,false)
  value=Util.Event.normalize_event_list(value) or {}
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
  Interface:export(name):configure(value)
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
    Interface.forspecs(specs,function(mapspec)
     Interface:add(mapspec):create()
    end)
   end
  end
  if preset.after then
   Util.eval(preset.after,plugin)
  end
 end,
}
local Preset={}
function Preset.apply(specs)
 local priority=2^10
 local normname=Util.Cache.create_simple(Util.Lazy.normname)
 local getname=Util.Cache.create_simple(Util.Lazy.getname)
 local preset_modmap; Util.lazy(function()
  return Util.create_modmap("hc-nvim.config.preset")
 end,function(t) preset_modmap=t end)
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
 local plain_spec_list=Util.Lazy.list_spec(specs)
 for index,spec in ipairs(plain_spec_list) do
  if spec.import~=nil then
   goto continue
  end
  -- get preset
  local name=getname(spec)
  if name==nil then
   goto continue
  end
  local modname=normname(name)
  local preset=PluginPresets[modname]
  local base=preset.base
  if type(base)=="table" then
   for k,v in pairs(base) do
    spec[k]=v
   end
  end
  if Config.platform.vscode and spec.vscode==false then
   spec.enabled=false
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
  if spec.priority==nil then
   spec.priority=priority
   priority=priority-1
  end
  --  if spec.auto==true then
  --   spec.lazy=vim.fn.argc()==0
  --  end
  if spec.lazy==nil then
   spec.lazy=true
  end
  plain_spec_list[index]=spec
  ::continue::
 end
 return plain_spec_list
end
return Preset
