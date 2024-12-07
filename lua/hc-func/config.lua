local Util=require("hc-nvim.util")
local Validate=require("hc-nvim.util.validate")
local function empty_fn() end
---@class HCFunc.options
local default_options={
 cursorword={
  enabled=true,
  pattern=(function()
   local vmode={v=true,V=true,[""]=true}
   local fn=vim.fn
   return function()
    local text
    local mode=vim.fn.mode()
    if vmode[mode] then
     text=table.concat(fn.getregion(fn.getpos("."),fn.getpos("v"),{type=mode}),"\n")
    else
     text=vim.fn.expand("<cword>")
    end
    if #text<2 or #text>30 then
     return
    end
    text=vim.fn.escape(text,[[\]])
    local pattern
    if vmode[mode] then
     pattern=([[\V%s]]):format(text)
    else
     pattern=([[\V\<%s\>]]):format(text)
    end
    return pattern
   end
  end)(),
  hl_group="CursorWord",
  hl_opts={underline=true},
  autocmd={
   enter={
    "CursorMoved",
    "CursorMovedI",
    "CursorHold",
    "CursorHoldI",
    "WinEnter",
   },
   clear={"WinLeave"},
  },
  timer={
   enabled=true,
   delay=200,
   landing=100,
  },
 },
 rainbowcursor={
  enabled=true,
  colors=3600,
  throttle=5,
  hl_group="RainbowCursor",
  autocmd={
   enabled=true,
   event={"CursorMoved","CursorMovedI"},
   interval=3,
   loopover=360,
   refresh={"CursorMoved","CursorMovedI"},
  },
  timer={
   enabled=true,
   interval=200,
   loopover=360,
   refresh=200,
  },
 },
 toggler={
  enabled=true,
  ---@class HCFunc.toggler.rule
  ---@field default HCFunc.toggler.rule.entry
  ---@field [HCFunc.function.modname] HCFunc.toggler.rule.entry
  rule={
   ---@class HCFunc.toggler.rule.entry
   ---@field buftype table<string,boolean>
   ---@field filetype table<string,boolean>
   ---@field size_kb {[1]:number,[2]:number}
   ---@field cond (fun(buf:integer):boolean)|nil
   ---@field event {["on"|"off"|"rec"]:string}[]
   default={
    buftype={["*"]=true},
    filetype={["*"]=true},
    size_kb={0,1024},
    cond=nil,
    auto_suspend=false,
   },
  },
 },
 --- LSPs
 auto_format={
  enabled=true,
  opts={},
 },
 document_highlight={
  enabled=true,
  autocmd={
   enter={
    "CursorMoved",
    "CursorMovedI",
    "CursorHold",
    "CursorHoldI",
    "WinEnter",
   },
   clear={"WinLeave"},
  },
  timer={
   enabled=true,
   delay=200,
   landing=100,
  },
 },
 code_lens={
  enabled=true,
 },
}
setmetatable(default_options,{__newindex=empty_fn})
local valitab={
 cursorword={
  enabled="boolean",
  pattern="function",
  hl_group="string",
  hl_opts=Validate.mkdict("string","any"),
  autocmd={
   enter=Validate.mklist("string"),
   clear=Validate.mklist("string"),
  },
  timer={
   enabled="boolean",
   delay="integer",
   landing="integer",
  },
 },
 rainbowcursor={
  colors=Validate.mkunion("integer",Validate.mklist("string")),
  enabled="boolean",
  hl_group="string",
  autocmd={
   enabled="boolean",
   event=Validate.mkunion("false",Validate.mklist("string")),
   loopover="integer",
   interval=Validate.mkunion("false","integer"),
  },
  timer={
   enabled="boolean",
   interval=Validate.mkunion("false","integer"),
   refresh=Validate.mkunion("false","integer"),
   loopover="integer",
  },
 },
 toggler={
  enabled="boolean",
  rule=Validate.mkdict("string",{
   filetype=Validate.mkoptional(Validate.mkdict("string","boolean")),
   size_kb=Validate.mkoptional({"number","number"}),
   cond=Validate.mkoptional("function"),
  }),
 },
 auto_format={
  enabled="boolean",
  opts="table",
 },
 document_highlight={
  enabled="boolean",
  autocmd={
   enter=Validate.mklist("string"),
   clear=Validate.mklist("string"),
  },
  timer={
   enabled="boolean",
   delay="integer",
   landing="integer",
  },
 },
 code_lens={
  enabled="boolean",
 },
}
local current_options=default_options
local M={}
M.options=Util.Reference.create(setmetatable({},{
 __index=function(_,k)
  return current_options[k]
 end,
}))
--- Lua ls notation
if false then
 M.options=default_options
end
function M.fini()
 current_options=default_options
end
function M.setup(opts)
 local new_options=vim.tbl_deep_extend("force",default_options,opts)
 Validate.validate_assert("<hc-func.config>.options",new_options,valitab)
 current_options=new_options
end
return M
