local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
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
     return table.concat({Util.I18n.get({"modemap",raw}),raw}," ")
    end),
   },
  },
  lualine_b={
   "branch",
   "diff",
   {"filename"},
   {"filesize"},
   {Util.when({event="OptionSet",pattern="filetype",func=function() return vim.bo.filetype end})},
  },
  lualine_c={
  },
  lualine_x={
   {Util.when({
    event={"BufReadPost","BufNewFile"},
    func=function()
     return vim.uv.fs_stat(vim.api.nvim_buf_get_name(0)).type
    end,
   })},
   {
    function() return vim.bo.fileencoding end,
    cond=function() return vim.bo.buftype=="" end,
   },
   {
    function() return vim.bo.fileformat end,
    cond=function() return vim.bo.buftype=="" end,
   },
   {
    function() return vim.bo.buftype end,
   },
   {
    function() return vim.bo.commentstring:gsub("%%","%%%%") end,
    cond=function() return vim.bo.buftype=="" end,
   },
   {
    Util.when({
     event="OptionSet",
     pattern="expandtab",
     func=function() return ("%s:%s/%s"):format(vim.bo.expandtab and "space" or "tab",vim.bo.shiftwidth,vim.bo.tabstop) end,
    }),
    cond=function()
     return vim.bo.buftype==""
    end,
   },
   {
    Util.when({
     event="OptionSet",
     pattern="foldenable,foldmethod,foldlevel",
     func=function()
      return vim.o.foldenable and ("%s:%d"):format(vim.wo.foldmethod,vim.wo.foldlevel) or ""
     end,
    }),
    cond=function()
     return vim.bo.buftype==""
    end,
   },
   {Util.when({
    event="OptionSet",
    pattern="wrap",
    func=function() return vim.wo.wrap and "wrap" or "nowrap" end,
   })},
  },
  lualine_y={
   {"diagnostics",symbols=require("hc-nvim.rsc").sign[Config.ui.sign]},
   --- Lsp
   {
    Util.when({
     event={"LspAttach"},
     func=function()
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
     end,
    }),
    cond=function()
     return vim.bo.buftype==""
    end,
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
   {Util.when({
    event={"TabEnter","BufEnter","WinEnter"},
    func=function()
     return vim.api.nvim_get_current_tabpage()
      .."|"..vim.api.nvim_get_current_win()
      .."|"..vim.api.nvim_get_current_buf()
    end,
   })},
   --- VRange
   {Util.when({
    event={"CursorMoved","ModeChanged"},
    func=function()
     if Util.is_visualmode() then
      local vmode=Util.get_vmode()
      local fn=vim.fn
      local cl=fn.line(".")
      local cc=fn.virtcol(".")
      local vl=fn.line("v")
      local vc=fn.virtcol("v")
      return ("%s:%s|%s:%s|%s:%s"):format(
       vl,vc,cl,cc,math.abs(vl-cl)+1,vmode=="V" and "$" or math.abs(vc-cc)+1
      )
     end
     return ""
    end,
   })},
   --- Line and column progreass
   {Util.when({
    event={"CursorMoved","CursorMovedI"},
    func=function()
     local fn=vim.fn
     local cl=fn.line(".")
     local cc=fn.virtcol(".")
     local el=fn.line("$")
     local ec=fn.virtcol("$")
     return ("%s/%s %s/%s"):format(cl,el,cc,ec)
    end,
   })},
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
