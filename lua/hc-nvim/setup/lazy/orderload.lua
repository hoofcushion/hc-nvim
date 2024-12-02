---@diagnostic disable: duplicate-set-field
local Loader=require("lazy.core.loader")
local Config=require("lazy.core.config")
local Util=require("lazy.core.util")
---@class Loader
---@param plugins string|LazyPlugin|string[]|LazyPlugin[]
---@param reason {[string]:string}
---@param opts? {force:boolean} when force is true, we skip the cond check
function Loader.load(plugins,reason,opts)
 ---@diagnostic disable-next-line: cast-local-type
 plugins=(type(plugins)=="string" or plugins.name) and {plugins} or plugins
 ---@cast plugins (string|LazyPlugin)[]
 local queue={}
 for _,plugin in pairs(plugins) do
  if type(plugin)=="string" then
   if Config.plugins[plugin] then
    plugin=Config.plugins[plugin]
   elseif Config.spec.disabled[plugin] then
    goto continue
   else
    Util.error("Plugin "..plugin.." not found")
    goto continue
   end
  end
  if not plugin._.loaded then
   table.insert(queue,plugin)
  end
  ::continue::
 end
 table.sort(queue,function(a,b)
  return a.priority and b.priority and a.priority>b.priority
 end)
 for _,plugin in ipairs(queue) do
  Loader._load(plugin,reason,opts)
 end
end
