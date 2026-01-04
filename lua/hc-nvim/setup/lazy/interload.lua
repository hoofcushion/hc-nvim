---@diagnostic disable: duplicate-set-field
--- Rewrite lazy.nvim to use delay loading mechanism
local Config=require("hc-nvim.config")
if Config.performance.plugin.load_cooldown==0 then
 return
end
local Loader=require("lazy.core.loader")
local invalid_events={
 ["sourcecmd"]=true,
 ["sourcepost"]=true,
 ["sourcepre"]=true,
 ["vimenter"]=true,
 ["cmdlineenter"]=true,
 ["insertenter"]=true,
 ["user"]=true,
}
local function is_valid_event(event)
 if event==nil then
  return false
 end
 event=event:lower()
 local _,e=string.find(event," ",1,false)
 if e~=nil then
  event=event:sub(1,e-1)
 end
 if invalid_events[event] then
  return false
 end
 return true
end
local raw=Loader._load
local TaskSequence=require("hc-nvim.util.task_sequence").new()
---@param plugin LazyPlugin
---@param reason {[string]:string}
---@param opts? {force:boolean}
function Loader._load(plugin,reason,opts)
 if is_valid_event(reason.event) then
  TaskSequence:add(vim.schedule_wrap(function()
   raw(plugin,reason,opts)
  end))
  TaskSequence:start(Config.performance.plugin.load_cooldown)
  return
 end
 raw(plugin,reason,opts)
end
