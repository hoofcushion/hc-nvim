---@diagnostic disable: duplicate-set-field
--- Rewrite lazy.nvim to use delay loading mechanism
local Loader=require("lazy.core.loader")
local Config=require("hc-nvim.config")
local startuptime_events={
 ["sourcecmd"]=true,
 ["sourcepost"]=true,
 ["sourcepre"]=true,
 ["bufenter"]=true,
 ["bufreadpost"]=true,
 ["bufnewfile"]=true,
 ["vimenter"]=true,
 ["uienter"]=true,
}
local raw=Loader._load
local TaskSequence=require("hc-nvim.util.task_sequence").new()
---@param plugin LazyPlugin
---@param reason {[string]:string}
---@param opts? {force:boolean}
function Loader._load(plugin,reason,opts)
 local event=reason.event
 if  Config.performance.plugin.load_cooldown~=0
 and plugin.lazy==true
 and event~=nil
 and not startuptime_events[event:lower()] then
  TaskSequence:add(function()
   raw(plugin,reason,opts)
  end)
  TaskSequence:start(Config.performance.plugin.load_cooldown)
  return
 end
 raw(plugin,reason,opts)
end
