local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
local I18N=require("hc-nvim.setup.i18n")
if false then
 ---@class LualinePreset
 ---@field getter function
 ---@field cond function?
 local Preset={}
 ---@class LualinePresets
 local Presets=LuaTyped.dict(LuaTyped.string,Preset)
end
--- Preset definition
---@type LualinePresets
local Presets={
 ---@type LualinePreset
 filetype={
  getter=Util.Response.from_event({
   event="OptionSet",
   func=function() return vim.bo.filetype end,
  }),
 },
 filesystem_type={
  getter=Util.Response.from_event({
   event={"BufReadPost","BufWritePost"},
   func=function()
    local stat=vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
    if not stat then
     return
    end
    local fs_type=stat.type
    return I18N.instance:tbl_get({"filetype",fs_type})
   end,
  }),
  cond=function()
   return vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))~=nil
  end,
 },
 fileencoding={
  getter=function()
   return vim.bo.fileencoding
  end,
  cond=function(t)
   return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
  end,
 },
 fileformat={
  getter=function()
   local f=vim.bo.fileformat
   return f=="dos" and [[\r\n]]
    or f=="unix" and [[\n]]
    or f=="max" and [[\r]]
    or ""
  end,
  cond=function()
   return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
  end,
 },
 fold_info={
  getter=Util.Response.from_event({
   event="OptionSet",
   pattern="foldenable,foldmethod,foldlevel",
   func=function()
    return vim.o.foldenable and ("%s:%d"):format(I18N.instance:tbl_get({"foldmethod",vim.wo.foldmethod}),vim.wo.foldlevel) or ""
   end,
  }),
  cond=function()
   return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
  end,
 },
 wrap_status={
  getter=Util.Response.from_event({
   event="OptionSet",
   pattern="wrap",
   func=function()
    local id=vim.wo.wrap and "wrap" or "nowrap"
    return I18N.instance:tbl_get({"wrap",id})
   end,
  }),
 },
 buf_win_tab={
  getter=Util.Response.from_event({
   event={"TabEnter","BufEnter","WinEnter"},
   func=function()
    local format_template=I18N.instance:tbl_get({"format_template","lualine_bwt_info"})
    return (format_template):format(
     vim.api.nvim_get_current_tabpage(),
     vim.api.nvim_get_current_win(),
     vim.api.nvim_get_current_buf()
    )
   end,
  }),
 },
 visual_range={
  getter=Util.Response.from_event({
   event={"CursorMoved","ModeChanged"},
   func=function()
    local vmode=Util.get_vmode()
    local fn=vim.fn
    local cl=fn.line(".")
    local cc=fn.virtcol(".")
    local vl=fn.line("v")
    local vc=fn.virtcol("v")
    return ("%s:%s %s:%s %sx%s"):format(
     vl,vc,cl,cc,math.abs(vl-cl)+1,vmode=="V" and "$" or math.abs(vc-cc)+1
    )
   end,
  }),
  cond=function()
   return Util.is_visualmode()
  end,
 },
 line_col_progress={
  getter=Util.Response.from_event({
   event={"CursorMoved","CursorMovedI"},
   func=function()
    local fn=vim.fn
    local cl=fn.line(".")
    local cc=fn.virtcol(".")
    local el=fn.line("$")
    local ec=fn.virtcol("$")
    local llen=math.ceil(math.log(el,10))
    local clen=math.ceil(math.log(el,10))
    if Config.ui.sign=="hanzi" then
     return ("行:%0"..llen.."d/%0"..llen.."d 列:%0"..clen.."d/%0"..clen.."d"):format(cl,el,cc,ec)
    else
     return ("L:%0"..llen.."d/%0"..llen.."d C:%0"..clen.."d/%0"..clen.."d"):format(cl,el,cc,ec)
    end
   end,
  }),
 },
 searchcount={
  getter="searchcount",
  cond=function() return vim.v.hlsearch==1 end,
 },
 marks={
  getter=function()
   local marks=vim.fn.getmarklist(0)
   if next(marks)~=nil then
    local list={}
    for _,v in ipairs(marks) do
     table.insert(list,v.mark:sub(-1))
    end
    return table.concat(list)
   end
  end,
 },
 buftype={
  getter=function()
   return I18N.instance:tbl_get({"buftype",vim.bo.buftype})
  end,
 },
 mode={
  getter="mode",
  icons_enabled=true,
  fmt=Util.Cache.create(function()
   local raw=vim.fn.mode(1)
   return table.concat({I18N.instance:tbl_get({"modemap",raw}),raw}," ")
  end),
 },
}
return {
 options={
  globalstatus=true,
  component_separators={left="",right=""},
  section_separators={left="",right=""},
  refresh={
   statusline=Config.performance.refresh,
   tabline=Config.performance.refresh,
   winbar=Config.performance.refresh,
   refresh_time=Config.performance.refresh,
   events={"BufEnter"},
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
 ---@type table<string,(table|lualine.section|{[1]:lualine.section})[]>
 sections={
  lualine_a={
   {Presets.mode.getter},
  },
  lualine_b={
   {"branch"},
   {"diff"},
  },
  lualine_c={
   {"filesize"},
   {Presets.filetype.getter},
   {Presets.filesystem_type.getter},
   {Presets.buftype.getter},
   {Presets.fileencoding.getter,  cond=Presets.fileencoding.cond},
   {Presets.fileformat.getter},
  },
  lualine_x={
   {Presets.fold_info.getter, cond=Presets.fold_info.cond},
   {Presets.wrap_status.getter},
  },
  lualine_y={
   {"diagnostics",      symbols=require("hc-nvim.config.rsc").sign[Config.ui.sign]},
   {"lsp_status"},
   {Presets.marks.getter},
  },
  lualine_z={
   {Presets.searchcount.getter,     cond=Presets.searchcount.cond},
   {Presets.buf_win_tab.getter},
   {Presets.visual_range.getter,    cond=Presets.visual_range.cond},
   {Presets.line_col_progress.getter},
  },
 },
 tabline={
  lualine_a={
  },
  lualine_b={
   {"buffers"},
  },
  lualine_c={
   {"filename",path=1},
  },
  lualine_x={
   {"windows"},
  },
  lualine_y={
  },
  lualine_z={
   {"tabs"},
  },
 },
}
