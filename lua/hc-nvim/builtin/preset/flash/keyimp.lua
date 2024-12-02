local flash=require("flash")
local flash_ts=require("flash.plugins.treesitter")
local W=require("hc-nvim.util").Wrapper
local no_offset={0,0}
local pattern={
 line={
  search={mode="search",max_length=0},
  label={before=true,after=false},
  jump={pos="start"},
  pattern=[[^]],
  highlight={matches=false},
 },
 line_non_blank={
  search={mode="search",max_length=0},
  label={before=true,after=false},
  jump={pos="start"},
  pattern=[[\v\S.+$]],
  highlight={matches=false},
 },
 line_end={
  search={mode="search",max_length=0},
  label={before=true,after=false},
  jump={pos="end"},
  pattern=[[$]],
  highlight={matches=false},
 },
 line_end_non_blank={
  search={mode="search",max_length=0},
  label={before=true,after=false},
  jump={pos="end"},
  pattern=[[\v\s*$]],
  highlight={matches=false},
 },
 cword=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=false},
   jump={pos="start"},
  },
  function(x)
   x.pattern=vim.fn.expand("<cword>")
  end
 ),
 cword_range=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=no_offset},
   jump={pos="range"},
  },
  function(x) x.pattern=vim.fn.expand("<cword>") end
 ),
 selection=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=true,after=true},
   jump={pos="range"},
  },
  (function()
   local fn=vim.fn
   local api=vim.api
   local function get_vs()
    local save=fn.getreg("@a",1)
    if api.nvim_get_mode().mode=="n" then
     api.nvim_feedkeys('gv"ay',"nx",false)
    else
     api.nvim_feedkeys('"ay',"nx",false)
    end
    local ret=fn.getreg("@a",1)
    fn.setreg("@a",save)
    return ret
   end
   return function(x) x.pattern=get_vs() end
  end)()
 ),
 e={
  search={mode="search",max_length=0},
  label={before=false,after=no_offset},
  jump={pos="start"},
  pattern=[[\w\>]],
  highlight={matches=false},
 },
 ge={
  search={mode="search",max_length=0},
  label={before=no_offset,after=false},
  jump={pos="start"},
  pattern=[[\<\w]],
  highlight={matches=false},
 },
 h=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=false},
   jump={pos="start"},
   highlight={matches=false},
  },
  function(x)
   local cursor=vim.api.nvim_win_get_cursor(0)
   local l,c=cursor[1],cursor[2]+1
   x.pattern=string.format([[\v%%%dl%%<%dc|%%%dl%%>0c]],l,c,l-1)
  end
 ),
 l=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=false},
   jump={pos="start"},
   highlight={matches=false},
  },
  function(x)
   local cursor=vim.api.nvim_win_get_cursor(0)
   local l,c=cursor[1],cursor[2]+1
   x.pattern=string.format([[\v%%%dl%%>%dc|%%%dl%%>0c]],l,c,l+1)
  end
 ),
 j=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=false},
   jump={pos="start"},
   highlight={matches=false},
  },
  function(x)
   local cursor=vim.api.nvim_win_get_cursor(0)
   local l,c=cursor[1],cursor[2]+1
   x.pattern=string.format([[\v%%>%dl(%%%dc|%%<%dc$)]],l,c,c)
  end
 ),
 k=W.modifier(
  {
   search={mode="search",max_length=0},
   label={before=no_offset,after=false},
   jump={pos="start"},
   highlight={matches=false},
  },
  function(x)
   local cursor=vim.api.nvim_win_get_cursor(0)
   local l,c=cursor[1],cursor[2]+1
   x.pattern=string.format([[\v%%<%dl(%%%dc|%%<%dc$)]],l,c,c)
  end
 ),
}
return {
 {name=NS.flash_jump,                   rhs=flash.jump},
 {name=NS.flash_jump_h,                 rhs=W.fn_eval(flash.jump,pattern.h)},
 {name=NS.flash_jump_j,                 rhs=W.fn_eval(flash.jump,pattern.j)},
 {name=NS.flash_jump_k,                 rhs=W.fn_eval(flash.jump,pattern.k)},
 {name=NS.flash_jump_l,                 rhs=W.fn_eval(flash.jump,pattern.l)},
 {name=NS.flash_jump_e,                 rhs=W.fn(flash.jump,pattern.e)},
 {name=NS.flash_jump_ge,                rhs=W.fn(flash.jump,pattern.ge)},
 {name=NS.flash_jump_line,              rhs=W.fn(flash.jump,pattern.line)},
 {name=NS.flash_jump_line_non_blank,    rhs=W.fn(flash.jump,pattern.line_non_blank)},
 {name=NS.flash_jump_line_end,          rhs=W.fn(flash.jump,pattern.line_end)},
 {name=NS.flash_jump_line_end_non_blank,rhs=W.fn(flash.jump,pattern.line_end_non_blank)},
 {name=NS.flash_jump_cword,             rhs=W.fn_eval(flash.jump,pattern.cword)},
 {name=NS.flash_jump_cword_range,       rhs=W.fn_eval(flash.jump,pattern.cword_range)},
 {name=NS.flash_jump_selection,         rhs=W.fn_eval(flash.jump,pattern.selection)},
 {name=NS.flash_treesitter_jump,        rhs=flash_ts.jump},
 {name=NS.flash_treesitter_search,      rhs=flash_ts.search},
 {name=NS.flash_treesitter_start,       rhs=W.fn(flash_ts.search,pattern.line)},
 {name=NS.flash_remote,                 rhs=flash.remote},
 {name=NS.flash_remote_line,            rhs=W.fn(flash.remote,pattern.line)},
 {name=NS.flash_toggle,                 rhs=flash.toggle},
}
