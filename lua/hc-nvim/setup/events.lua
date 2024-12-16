local Util=require("hc-nvim.util")
local M={}
function M.Create(name,events,opts)
 return Util.Event.new(events):create_user_event(name,opts)
end
--- Take a list of events and trigger a new event when all of them happen.
---@param events string|EventSpec|(string|EventSpec)[]
function M.AllHappen(events)
 return Util.Event.new(events):all_happen()
end
function M.Sequence(events)
 return Util.Event.new(events):sequence()
end
function M.RootPattern(pattern)
 return M.Create(
  "RootPattern: "..table.concat(Util.totable(pattern),", "),
  {"BufRead"},
  {trigger=function() return vim.fs.root(0,pattern)~=nil end}
 )
end
function M.LazyLoad(name)
 return M.Create(
  "LazyLoad "..name,
  "User LazyLoad",
  {
   trigger=function(ev)
    return ev.data==name
   end,
  }
 )
end
M.DirEnter=M.Create("DirEnter","BufEnter",{
 trigger=function(ev)
  local stat=vim.uv.fs_stat(ev.file)
  return stat~=nil and stat.type=="directory"
 end,
})
M.FileEnter=M.Create("FileEnter","BufEnter",{
 trigger=function(ev)
  return ev.file~=""
 end,
})
M.FileWinEnter=M.Create("FileWinEnter","BufWinEnter",{
 trigger=function(ev)
  return ev.file~=""
 end,
})
M.NeoConfig=M.Create("NeoConfig","BufEnter",{
 trigger=function(ev)
  if Util.is_profile(ev.file) then
   return true
  end
 end,
})
M.LeaveDashBoard=M.Create("LeaveDashBoard","BufWipeOut",{
 trigger=function(ev)
  return ev.buf==1
 end,
})
-- local t=vim.uv.new_timer()
-- local cb=function()
--  vim.schedule(function()
--   vim.api.nvim_exec_autocmds("User",{pattern="Idle"})
--   t:stop()
--  end)
-- end
-- vim.api.nvim_create_autocmd({"CursorMoved","CursorMovedI"},{
--  callback=function(x)
--   t:start(1000,0,cb)
--  end,
-- }
-- )
-- M.Idle={event="User",pattern="Idle"}
return M
