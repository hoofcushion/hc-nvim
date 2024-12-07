local Config=require("hc-func.config")
local Util=require("hc-nvim.util")
local Options=Config.options.cursorword
local CursorWordAu=Util.Autocmd.new()
local Highlight=Util.Highlight.new()
local Timer=Util.Timer.new()
local env=Util.LocalEnv.new()
local lock=Util.TaskLock.new()
--- ---
--- Matcher class
--- ---
local Match={
 matches={}, ---@type table<integer,integer>
}
---@param group string
---@param pattern string
function Match.add(group,pattern)
 local id=vim.fn.matchadd(group,pattern)
 if id==-1 then
  return
 end
 Match.matches[id]=vim.api.nvim_get_current_win()
end
---@param id integer
---@param win integer
function Match.del(id,win)
 vim.schedule(function()
  pcall(vim.fn.matchdelete,id,win)
 end)
 Match.matches[id]=nil
end
function Match.fini()
 for id,win in pairs(Match.matches) do
  Match.del(id,win)
 end
end
local CursorWord={}
function CursorWord.match()
 local pattern=Options.pattern()
 if pattern==nil then
  return
 end
 if pattern==env.buffer.current_pattern then
  return
 end
 CursorWord.clear()
 env.buffer.current_pattern=pattern
 Match.add(Options.hl_group,pattern)
end
function CursorWord.clear()
 Match.fini()
 env.buffer.current_pattern=nil
end
CursorWord.match=lock:bind(CursorWord.match)
local M={}
function M.activate()
 CursorWordAu:activate()
 Highlight:set()
 CursorWord.match()
end
function M.deactivate()
 CursorWordAu:deactivate()
 Highlight:clear()
 CursorWord.clear()
end
function M.enable()
 Highlight:add(Options.hl_group,Options.hl_opts)
 local event=Options.autocmd.enter
 local callback
 if Options.timer.enabled==true then
  local timer=Timer:new_timer()
  local landing,delay=Options.timer.landing,Options.timer.delay
  callback=function()
   if timer:is_active() then
    timer:start(landing,0,CursorWord.match)
    return
   end
   timer:start(delay,0,CursorWord.match)
  end
 else
  callback=CursorWord.match
 end
 CursorWordAu:add({{event,{callback=callback}}})
 CursorWordAu:add({{Options.autocmd.clear,{callback=CursorWord.clear}}})
 CursorWordAu:create()
end
function M.disable()
 CursorWordAu:fini()
 Highlight:fini()
 Timer:fini()
 env:reset()
end
return M
