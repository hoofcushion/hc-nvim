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
    return ev.file~="" and vim.fs.root(0,pattern)==vim.fs.normalize(vim.fn.getcwd())
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
M.AfterEnter=Util.Event.from("AfterEnter",function(exec)
 vim.api.nvim_create_autocmd("VimEnter",{
  callback=function()
   vim.schedule(exec)
  end,
 })
end)
M.File=Util.Event.create({
 name="File",
 any={
  event={"BufEnter"},
  cond=function(ev)
   return ev.file~=""
  end,
 },
})
local parser_files=setmetatable({},{
 __index=function(tbl,key)
  rawset(tbl,key,vim.api.nvim_get_runtime_file("parser/"..key..".*",false))
  return rawget(tbl,key)
 end,
})
M.Treesitter=Util.Event.create({
 name="Treesitter",
 any={
  event="FileType",
  cond=function(ev)
   local ts=vim.treesitter
   local ft=vim.bo[ev.buf].filetype
   local lang=ts.language.get_lang(ft)
    or ts.language.get_lang(vim.split(ft,".",{plain=true})[1])
    or ft
   local has_lang=lang and #lang>0 and (vim._ts_has_language(lang) or #parser_files[lang]>0)
   return has_lang
  end,
 },
})
return M
