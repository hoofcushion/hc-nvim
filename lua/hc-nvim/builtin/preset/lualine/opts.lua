local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
local cache={}
--- Update value of function when specific event happens
---@generic F
---@param event vim.api.keyset.create_autocmd.events
---@param func F
---@return F
local function when(event,pattern,func)
 if cache[event]==nil then
  vim.api.nvim_create_autocmd(event,{
   pattern=pattern,
   callback=function()
    cache[event]=true
   end,
  })
  cache[event]=true
 end
 return function()
  if cache[event]==true then
   cache[event]=Util.packlen(func())
  end
  return Util.unpacklen(cache[event])
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
    fmt=(function()
     return function()
      local raw=vim.fn.mode(1)
      return "["..raw.."] "..(Util.I18n.get("modemap",raw) or "")
     end
    end)(),
   },
  },
  lualine_b={
   "branch",
   "diff",
  },
  lualine_c={
   {"filename",path=3},
   "filesize",
   {function () return vim.bo.encoding end},
   {function () return vim.bo.fileformat end},
   {function () return vim.bo.filetype end},
   {function() return vim.bo.buftype end},
  },
  lualine_x={},
  lualine_y={
   {
    [1]="diagnostics",
    symbols=require("hc-nvim.rsc").sign[Config.ui.sign],
   },
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
   {function() return ("%s: %s/%s"):format(vim.bo.expandtab and "space" or "tab",vim.bo.softtabstop,vim.bo.tabstop) end},
   {function () return vim.o.foldenable and ("%s: %d"):format(vim.o.foldmethod,vim.o.foldlevel) or "nofold" end},
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
   {
    [1]="searchcount",
    cond=function() return vim.v.hlsearch==1 end,
   },
   --- Current buf win tab
   function()
    return vim.api.nvim_get_current_tabpage()
     .."|"..vim.api.nvim_get_current_win()
     .."|"..vim.api.nvim_get_current_buf()
   end,
   --- Position
   "progress",
   "location",
  },
 },
 tabline={
  lualine_a={},
  lualine_b={
   {"buffers",show_filename_only=true},
  },
  lualine_c={},
  lualine_x={
   {"windows",show_filename_only=true},
  },
  lualine_y={},
  lualine_z={"tabs"},
 },
}
