---@diagnostic disable: duplicate-set-field
--- Rewrite lazy.nvim to use delay loading mechanism
local Loader=require("lazy.core.loader")
local Config=require("hc-nvim.config")
local startuptime_events={
 ["sourcecmd"]=true,
 ["sourcepost"]=true,
 ["sourcepre"]=true,
 ["cmdlineenter"]=true,
 ["insertenter"]=true,
}
local raw=Loader._load
local TaskSequence=require("hc-nvim.util.task_sequence").new()
local safestate=false
vim.api.nvim_create_autocmd("SafeState",{
 once=true,
 callback=function()
  TaskSequence:start(Config.performance.plugin.load_cooldown)
  safestate=true
 end,
})
---@param plugin LazyPlugin
---@param reason {[string]:string}
---@param opts? {force:boolean}
function Loader._load(plugin,reason,opts)
 local event=reason.event
 if  Config.performance.plugin.load_cooldown~=0
 and plugin.lazy==true
 and event~=nil
 and not startuptime_events[event:lower()]
 then
  TaskSequence:add(function()
   raw(plugin,reason,opts)
  end)
  if safestate then
   TaskSequence:start(Config.performance.plugin.load_cooldown)
  end
  return
 end
 raw(plugin,reason,opts)
end
