local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
local cache={}
--- PERF:
--- Update value of function when specific event happens
--- Greatly improve lualine speed.
---@generic F
---@param event vim.api.keyset.create_autocmd.events|vim.api.keyset.create_autocmd.events[]
---@param func F
---@return F
local function when(event,pattern,func)
 if cache[func]==nil then
  vim.api.nvim_create_autocmd(event,{
   pattern=pattern,
   callback=function()
    cache[func]=true
   end,
  })
  cache[func]=true
 end
 return function()
  if cache[func]==true then
   cache[func]=Util.packlen(func())
  end
  return Util.unpacklen(cache[func])
 end
end
return {
 options={
  component_separators={left="",right=""},
  section_separators={left="",right=""},
  refresh={
   statusline=Config.performance.refresh,
   tabline=Config.performance.refresh,
   winbar=Config.performance.refresh,
  },
 },
 ---@alias lualine.sections
 ---| "branch" (git branch)
 ---| "buffers" (shows currently available buffers)
 ---| "diagnostics" (diagnostics count from your preferred source)
 ---| "diff" (git diff status)
 ---| "encoding" (file encoding)
 ---| "fileformat" (file format)
 ---| "filename"
 ---| "filesize"
 ---| "filetype"
 ---| "hostname"
 ---| "location" (location in file in line:column format)
 ---| "mode" (vim mode)
 ---| "progress" (%progress in file)
 ---| "searchcount" (number of search matches when hlsearch is active)
 ---| "selectioncount" (number of selected characters or lines)
 ---| "tabs" (shows currently available tabs)
 ---| "windows" (shows currently available windows)
 ---@alias lualine.section lualine.sections|string|fun():string
 ---@type table<string,(lualine.section|lualine.section[]|{[1]:lualine.section})>
 sections={
  lualine_a={
   {
    "mode",
    icons_enabled=true,
    fmt=Util.Cache.create(function()
     local raw=vim.fn.mode(1)
     return (Util.I18n.get("modemap",raw) or "").." "..raw
    end),
   },
  },
  lualine_b={
   "branch",
   "diff",
   {"filename"},
   {"filesize"},
   {when("OptionSet",nil,function() return vim.bo.filetype end)},
  },
  lualine_c={
  },
  lualine_x={
   {when({"BufEnter"},nil,function()
    local t=vim.b.file_subtype
    if not t then
     local info=vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
     t=info and info.type or "temp"
     vim.b.file_subtype=t
    end
    return t
   end)},
   {when("OptionSet",nil,function() return vim.bo.fileencoding end)},
   {when("OptionSet",nil,function() return vim.bo.encoding end)},
   {when("OptionSet",nil,function() return vim.bo.fileformat end)},
   {when("OptionSet",nil,function() return vim.bo.buftype end)},
   {when("OptionSet",nil,function() return vim.bo.commentstring:gsub("%%","%%%%") end)},
   {when("OptionSet",nil,function() return ("%s:%s/%s"):format(vim.bo.expandtab and "space" or "tab",vim.bo.shiftwidth,vim.bo.tabstop) end)},
   {when("OptionSet",nil,function()
    return vim.o.foldenable and ("%s:%d"):format(vim.bo.foldmethod,vim.bo.foldlevel) or ""
   end)},
   {when("OptionSet",nil,function() return vim.wo.wrap and "wrap" or "nowrap" end)},
  },
  lualine_y={
   {"diagnostics",symbols=require("hc-nvim.rsc").sign[Config.ui.sign]},
   --- Lsp
   {
    when("LspAttach",nil,function()
     local clients=vim.lsp.get_clients({bufnr=0})
     if next(clients)~=nil then
      local ret={}
      for _,v in ipairs(clients) do
       table.insert(ret,("%s:%d"):format(v.name,v.id))
      end
      if next(ret)~=nil then
       return table.concat(ret," ")
      end
     end
     return ""
    end),
   },
   --- Marks
   {
    function()
     local marks=vim.fn.getmarklist("%")
     if next(marks)~=nil then
      local list={}
      for _,v in ipairs(marks) do
       table.insert(list,v.mark:sub(-1))
      end
      return table.concat(list)
     end
    end,
   },
  },
  lualine_z={
   --- Search
   {"searchcount",cond=function() return vim.v.hlsearch==1 end},
   --- Current buf win tab
   {when({"TabEnter","BufEnter","WinEnter"},nil,function()
    return vim.api.nvim_get_current_tabpage()
     .."|"..vim.api.nvim_get_current_win()
     .."|"..vim.api.nvim_get_current_buf()
   end)},
   --- Position
   {when({"CursorMoved","CursorMovedI"},nil,function()
    local fn=vim.fn
    return ("%s:%s|%s:%s"):format(
     fn.line("."),
     fn.line("$"),
     fn.col("."),
     fn.col("$")
    )
   end)},
  },
 },
 tabline={
  lualine_a={},
  lualine_b={
   {"buffers"},
  },
  lualine_c={},
  lualine_x={
   {"windows"},
  },
  lualine_y={},
  lualine_z={"tabs"},
 },
}
