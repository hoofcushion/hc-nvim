local Util=require("hc-nvim.util")
local Loader=require("lazy.core.loader")
local Plugin=require("lazy.core.plugin")
local Mappings=require("hc-nvim.setup.mapping")
---@type table<string,(LazyPluginSpec|{base:LazyPluginSpec,keyimp:table,after:function,hook:{[1]:string[],[2]:function}[]})>
local PluginPresets=Util.Cache.table(function(name)
 local prefix="hc-nvim.builtin.preset."..name.."."
 return Util.Cache.table(function(field)
  local modname=prefix..field
   return Util.load_local_mod(modname)
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
function Hook:add(hooks)
 local checked=self.checked
 for _,v in ipairs(hooks) do
  local cond={}
  for _,name in pairs(v[1]) do
   if checked[name]==nil then
    cond[name]=true
   end
  end
  local hook={cond=cond,func=v[2]}
  table.insert(self.hooks,hook)
 end
end
function Hook:check(name)
 local checked=self.checked
 local hooks=self.hooks
 checked[name]=true
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
local PresetGetter={
 keys=function(plugin,field,orig,preset,name)
  orig=orig or preset[field]
  local val
  ---@diagnostic disable-next-line: missing-fields
  val=Plugin._values(plugin,{[field]=orig},field,false)
  Mappings:export(name):lazykeys(val)
  if orig==nil and next(val)==nil then
   val=nil
  end
  Util.deepset(plugin,field,val)
  return val
 end,
 event=function(plugin,field,orig,preset,_)
  orig=orig or preset[field]
  local val
  ---@diagnostic disable-next-line: missing-fields
  val=Plugin._values(plugin,{[field]=orig},field,false)
  val=Util.Event.parse(val)
  if orig==nil and next(val)==nil then
   val=nil
  end
  Util.deepset(plugin,field,val)
  return val
 end,
 cmd=function(_,field,orig,preset,_)
  return orig or preset[field]
 end,
 opts=function(plugin,field,orig,preset,name)
  orig=orig or preset[field]
  local val
  ---@diagnostic disable-next-line: missing-fields
  val=Plugin._values(plugin,{[field]=orig},field,false)
  Mappings:export(name):configure(val)
  if orig==nil and next(val)==nil then
   val=nil
  end
  Util.deepset(plugin,field,val)
  return val
 end,
 config=function(plugin,field,orig,preset,name)
  orig=orig or preset[field]
  Util.deepset(plugin,field,orig)
  if plugin.config or plugin.opts then
   Loader.config(plugin)
  end
  local keyimp=Util.eval(preset.keyimp,plugin)
  if keyimp~=nil then
   Mappings.forspecs(keyimp,function(mapspec)
    Mappings:add(mapspec):start()
   end)
  end
  Util.eval(preset.after,plugin)
  local hook=preset.hook
  if hook then
   Hook:add(hook)
  end
  Hook:check(name)
  Hook:check(plugin.name)
 end,
}
local priority=2^10
local Preset={}
function Preset.apply(specs)
 return Util.Lazy.foreach(specs,function(spec)
  -- add priority
  if spec.priority==nil then
   spec.priority=priority
   priority=priority-1
  end
  if spec.auto==true then
   spec.lazy=vim.fn.argc()==0
  end
  if spec.vscode and not vim.g.vscode then
   spec.enabled=false
  end
  -- get preset
  local name=Util.Lazy.getname(spec)
  local modname=Util.Lazy.normname(name)
  local preset=PluginPresets[modname]
  for k,v in Util.ppairs(preset.base) do
   spec[k]=v
  end
  for field,getter in pairs(PresetGetter) do
   local orig=spec[field]
   spec[field]=function(plugin)
    return getter(plugin,field,orig,preset,modname)
   end
  end
 end)
end
return Preset
