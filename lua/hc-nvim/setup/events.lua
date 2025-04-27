local Util=require("hc-nvim.util")
local M={}
function M.RootPattern(pattern)
 return Util.Event.create({
  name="RootPattern: "..table.concat(Util.totable(pattern),", "),
  any={
   event="BufEnter",
   cond=function(ev)
    return ev.file~="" and vim.fs.root(0,pattern)~=nil
   end,
  },
 })
end
function M.LazyLoad(name)
 return Util.Event.create({
  name="LazyLoad"..name,
  any={
   event="User",
   pattern="LazyLoad",
   cond=function(ev)
    return ev.data==name
   end,
  },
 })
end
M.NeoConfig=Util.Event.create({
 name="NeoConfig",
 any={
  event={"VimEnter","BufEnter","BufAdd"},
  cond=function(ev)
   return Util.is_profile(vim.fs.normalize(ev.file))
  end,
 },
})
M.File=Util.Event.create({
 name="File",
 any={
  event={"VimEnter","BufEnter","BufAdd"},
  cond=function(ev)
   return ev.file~=""
  end,
 },
})
M.FileAdd=Util.Event.create({
 name="FileAdd",
 any={
  event="BufAdd",
  cond=function(ev)
   return ev.file~=""
  end,
 },
})
M.Treesitter=Util.Event.create({
 name="Treesitter",
 any={
  event="FileType",
  cond=function(ev)
   local M=require("nvim-treesitter.parsers")
   return M.has_parser(M.get_buf_lang(ev.buf))
  end,
 },
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
