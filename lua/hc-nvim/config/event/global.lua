local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Events
local M={}
function M.RootPattern(pattern)
 return HCNvim.Util.Event.create({
  name="RootPattern: "..table.concat(HCNvim.Util.totable(pattern),", "),
  any={
   event={"VimEnter","BufEnter","BufAdd"},
   calm=true,
   cond=function(ev)
    return ev.file~="" and vim.fs.root(0,pattern)==vim.fs.normalize(vim.fn.getcwd())
   end,
  },
 })
end
function M.LazyLoad(name)
 return HCNvim.Util.Event.create({
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
M.NeoConfig=HCNvim.Util.Event.create({
 name="NeoConfig",
 any={
  event={"BufEnter"},
  cond=function(ev)
   return HCNvim.Util.is_profile(vim.fs.normalize(ev.file))
  end,
 },
})
M.AfterEnter=HCNvim.Util.Event.from("AfterEnter",function(exec)
 vim.api.nvim_create_autocmd("VimEnter",{
  callback=function()
   vim.schedule(exec)
  end,
 })
end)
M.File=HCNvim.Util.Event.create({
 name="File",
 any={
  event={"BufEnter","BufNewFile","VimEnter","BufReadPost"},
  cond=function(ev)
   return ev.file~=""
  end,
 },
})
M.Directory=HCNvim.Util.Event.create({
 name="Directory",
 any={
  event={"BufEnter","BufNewFile","VimEnter","BufReadPost"},
  cond=function(ev)
   return vim.fn.isdirectory(ev.file)==1
  end,
 },
})
M.Treesitter=HCNvim.Util.Event.create({
 name="Treesitter",
 any={
  event="FileType",
  cond=function(ev)
   return HCNvim.Util.ts_has_parser(ev.buf)
  end,
 },
})
return M
