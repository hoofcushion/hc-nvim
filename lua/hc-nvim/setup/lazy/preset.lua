local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
local Loader=require("lazy.core.loader")
local Plugin=require("lazy.core.plugin")
local Mappings=require("hc-nvim.setup.mapping")
local preset_modmap=Util.create_modmap("hc-nvim.builtin.preset")
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
--- hook after specific plugin
local Hook={
 ---@alias pluginName string
 --- Track if a specific pluginName is already checked.
 ---@type table<pluginName,boolean>
 checked={},
 ---@alias hook {cond:table<pluginName,boolean>,func:function}
 ---@alias hookspec {[1]:table<pluginName,boolean>,[2]:function}
 --- The hook list.
 ---@type table<integer,hook>
 hooks={},
}
---@param hooks hookspec[]
function Hook.add(hooks)
 local checked=Hook.checked
 for _,v in ipairs(hooks) do
  local cond={}
  for _,name in pairs(v[1]) do
   if checked[name]~=true then
    cond[name]=true
   end
  end
  local hook={cond=cond,func=v[2]}
  table.insert(Hook.hooks,hook)
 end
end
function Hook.check(name)
 local checked=Hook.checked
 checked[name]=true
 --- update hooks
 local hooks=Hook.hooks
 for k,hook in pairs(hooks) do
  local cond=hook.cond
  if cond[name]~=nil then
   cond[name]=nil
   if next(cond)==nil then
    hook.func()
    hooks[k]=nil
   end
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
  if preset.hook then
   Hook.add(preset.hook)
  end
  Hook.check(name)
  Hook.check(plugin.name)
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
