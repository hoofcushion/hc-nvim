local Util=require("hc-nvim.util")
local Config=require("hc-func.config")
local Options=Config.options.cursorword
local CursorWordAu=Util.ConductedAutocmd.new()
local Highlight=Util.ConductedHighlight.new()
local Timer=Util.ConductedTimer.new()
local LocalEnv=Util.LocalEnv.new()
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
 if pattern==LocalEnv.buffer.current_pattern then
  return
 end
 CursorWord.clear()
 LocalEnv.buffer.current_pattern=pattern
 Match.add(Options.hl_group,pattern)
end
function CursorWord.clear()
 Match.fini()
 LocalEnv.buffer.current_pattern=nil
end
CursorWord.match=Util.throttle(0,vim.schedule_wrap(CursorWord.match))
local defaults={delay=200,landing=100,fn=function() end}
local function adaptive_debounce(opts)
 setmetatable(opts or {},{__index=defaults})
 local timer=Timer:get()
 return function()
  if timer:is_active() then
   timer:start(opts.landing,0,CursorWord.match)
   return
  end
  timer:start(opts.delay,0,CursorWord.match)
 end
end
local M={}
function M.activate()
 CursorWordAu:activate()
 Highlight:enable()
 CursorWord.match()
end
function M.deactivate()
 CursorWordAu:deactivate()
 Highlight:disable()
 CursorWord.clear()
end
function M.enable()
 Highlight:add(Options.hl_group,Options.hl_opts)
 local callback
 if Options.timer.enabled==true then
  callback=adaptive_debounce({
   fn=CursorWord.match,
   landing=Options.timer.landing,
   delay=Options.timer.delay,
  })
 else
  callback=CursorWord.match
 end
 CursorWordAu:add({{Options.autocmd.enter,{callback=callback}}})
 CursorWordAu:add({{Options.autocmd.clear,{callback=CursorWord.clear}}})
 CursorWordAu:enable()
end
function M.disable()
 CursorWordAu:fini()
 Highlight:fini()
 Timer:fini()
 LocalEnv:reset()
end
return M
