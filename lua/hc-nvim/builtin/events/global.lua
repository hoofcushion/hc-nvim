local Util=require("hc-nvim.util")
---@class Events
local M={}
function M.RootPattern(pattern)
 return Util.Event.create({
  name="RootPattern: "..table.concat(Util.totable(pattern),", "),
  any={
   event={"VimEnter","BufEnter","BufAdd"},
   calm=true,
   cond=function(ev)
    return ev.file~="" and vim.fs.root(0,".git")==vim.fs.normalize(vim.fn.getcwd())
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
  event={"BufEnter"},
  cond=function(ev)
   return Util.is_profile(vim.fs.normalize(ev.file))
  end,
 },
})
M.File=Util.Event.create({
 name="File",
 any={
  event={"BufEnter"},
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
   local ts=require("nvim-treesitter.parsers")
   return ts.has_parser(ts.get_buf_lang(ev.buf))
  end,
 },
})
return M
