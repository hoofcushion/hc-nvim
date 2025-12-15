local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
-- deque
local deque={
 s=1,
 e=0,
 l={},
}
function deque:append(v)
 self.e=self.e+1
 self.l[self.e]=v
end
function deque:pophead()
 local v=self.l[self.s]
 self.s=self.s+1
 return v
end
function deque:tail()
 return self.l[self.e]
end
function deque:len()
 return self.e-self.s+1
end
function deque.new()
 return setmetatable(
  {
   s=1,
   e=0,
   l={},
  },
  {
   __index=deque,
  }
 )
end
return {
 options={
  globalstatus=true,
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
   "filename",
  },
  lualine_c={
   "filesize",
   {Util.when({event="OptionSet",func=function() return vim.bo.filetype end})},
   {
    Util.when({
     event={"BufReadPost","BufNewFile"},
     func=function()
      local stat=vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
      if not stat then
       return ""
      end
      local filetype=stat.type
      return Util.I18n.get({"filetype",filetype})
     end,
    }),
    cond=function()
     return vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))~=nil
    end,
   },
   {
    function()
     return Util.I18n.get({"buftype",vim.bo.buftype})
    end,
   },
   {
    function() return vim.bo.fileencoding end,
    cond=function()
     return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
    end,
   },
   {
    function()
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
   {
    function() return vim.bo.commentstring:gsub("%%","%%%%") end,
    cond=function()
     return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
    end,
   },
  },
  lualine_x={
   {
    Util.when({
     event="OptionSet",
     pattern="expandtab",
     func=function()
      return ("%s:%s/%s"):format(vim.bo.expandtab and "·" or "-",vim.bo.shiftwidth,vim.bo.tabstop)
     end,
    }),
    cond=function()
     return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
    end,
   },
   {
    Util.when({
     event="OptionSet",
     pattern="foldenable,foldmethod,foldlevel",
     func=function()
      return vim.o.foldenable and ("%s:%d"):format(Util.I18n.get({"foldmethod",vim.wo.foldmethod}),vim.wo.foldlevel) or ""
     end,
    }),
    cond=function()
     return vim.api.nvim_buf_get_name(0)~="" and vim.bo.buftype~="nofile"
    end,
   },
   {Util.when({
    event="OptionSet",
    pattern="wrap",
    func=function()
     local id=vim.wo.wrap and "wrap" or "nowrap"
     return Util.I18n.get({"wrap",id})
    end,
   })},
  },
  lualine_y={
   {"diagnostics",symbols=require("hc-nvim.config.rsc").sign[Config.ui.sign]},
   --- Lsp
   {"lsp_status"},
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
     if Config.ui.sign=="hanzi" then
      return ("拓:%s 映:%s 坝:%s"):format(
       vim.api.nvim_get_current_tabpage(),
       vim.api.nvim_get_current_win(),
       vim.api.nvim_get_current_buf()
      )
     else
      return ("T:%s W:%s B:%s"):format(
       vim.api.nvim_get_current_tabpage(),
       vim.api.nvim_get_current_win(),
       vim.api.nvim_get_current_buf()
      )
     end
    end,
   })},
   --- VRange
   {
    Util.when({
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
   {(function()
    local chars=deque.new()
    vim.api.nvim_create_autocmd("InsertCharPre",{
     callback=function()
      local char=vim.v.char
      if char==nil then
       return
      end
      chars:append({char,Util.clock()})
     end,
    })
    local function get_cpm()
     local cur=Util.clock()
     for i=chars.s,chars.e do
      local v=chars.l[i]
      if cur-v[2]>60 then
       chars:pophead()
      else
       break
      end
     end
     return chars:len()
    end
    return function()
     if chars:len()==0 then
      return ""
     end
     --- auto hide in 5 s
     if Util.clock()-chars:tail()[2]>5 then
      return ""
     end
     return get_cpm().."c/m"
    end
   end)()},
   {(function()
    local moves=deque.new()
    local last_pos
    vim.api.nvim_create_autocmd("WinEnter",{
     callback=function(ev)
      if ev.file=="" or vim.bo[ev.buf].buftype=="nofile" then
       return
      end
      last_pos=vim.fn.getpos(".")
     end,
    })
    vim.api.nvim_create_autocmd({"CursorMoved","CursorMovedI"},{
     callback=function(ev)
      if ev.file=="" or vim.bo[ev.buf].buftype=="nofile" then
       return
      end
      local current_pos = {vim.fn.line("."),vim.fn.virtcol(".")}
      if last_pos==nil then
       last_pos=current_pos
       return
      end
      local cur=Util.clock()
      local row_dist=math.abs(current_pos[1]-last_pos[1])
      local col_dist=math.abs(current_pos[2]-last_pos[2])
      local distance=row_dist+col_dist
      moves:append({distance,cur})
      last_pos=current_pos
     end,
    })
    local function get_speed()
     local cur=Util.clock()
     local total_chars=0
     for i=moves.s,moves.e do
      local v=moves.l[i]
      if cur-v[2]>60 then
       moves:pophead()
      else
       total_chars=total_chars+v[1]
      end
     end
     return math.floor(total_chars)
    end
    return function()
     if moves:len()==0 then
      return ""
     end
     if Util.clock()-moves:tail()[2]>5 then
      return ""
     end
     return get_speed().."b/m"
    end
   end)()},
   --- Line and column progreass
   {Util.when({
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
