local Util=require("hc-nvim.util")
local Config={}
---@class HCFunc.options
Config.default={
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
   ---@type vim.api.keyset.events|vim.api.keyset.events[]
   enter={
    "CursorMoved",
    "CursorMovedI",
    "CursorHold",
    "CursorHoldI",
    "WinEnter",
   },
   ---@type vim.api.keyset.events|vim.api.keyset.events[]
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
   loopover=360/3,
   refresh=true,
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
  ---@field [string] HCFunc.toggler.rule.entry
  rule={
   ---@class HCFunc.toggler.rule.entry
   ---@field buftype table<string,boolean>
   ---@field filetype table<string,boolean>
   ---@field size_kb {[1]:number,[2]:number}
   ---@field cond (fun(buf:integer):boolean)|nil
   ---@field auto_suspend boolean|nil
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
local valitab={
 cursorword={
  enabled="boolean",
  pattern="function",
  hl_group="string",
  hl_opts=Util.Type.dict("string","any"),
  autocmd={
   enter=Util.Type.list("string"),
   clear=Util.Type.list("string"),
  },
  timer={
   enabled="boolean",
   delay="integer",
   landing="integer",
  },
 },
 rainbowcursor={
  colors=Util.Type.any({"integer",Util.Type.list("string")}),
  enabled="boolean",
  hl_group="string",
  throttle="positive",
  autocmd={
   enabled="boolean",
   event=Util.Type.any({"false",Util.Type.list("string")}),
   interval=Util.Type.any({"false","integer"}),
   loopover="integer",
   refresh=Util.Type.optional("boolean"),
  },
  timer={
   enabled="boolean",
   interval=Util.Type.any({"false","integer"}),
   loopover="integer",
   refresh=Util.Type.any({"false","integer"}),
  },
 },
 toggler={
  enabled="boolean",
  rule=Util.Type.dict("string",{
   buftype=Util.Type.optional(Util.Type.dict("string","boolean")),
   filetype=Util.Type.optional(Util.Type.dict("string","boolean")),
   size_kb=Util.Type.optional({"number","number"}),
   cond=Util.Type.optional("function"),
   auto_suspend=Util.Type.optional("boolean"),
  }),
 },
 auto_format={
  enabled="boolean",
  opts="table",
 },
 document_highlight={
  enabled="boolean",
  autocmd={
   enter=Util.Type.list("string"),
   clear=Util.Type.list("string"),
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
if UnitTest then
 UnitTest:add_case({name="hc-func",expect=true,test=function() return Util.Type.check_type(valitab,"config",Config.default) end})
end
Config.current=Config.default
Config.options=Util.Reference.get(function() return Config.current end)
function Config.fini()
 Config.current=Config.default
end
function Config.setup(opts)
 local new_options=vim.tbl_deep_extend("force",Config.current,opts)
 Util.try(
  function()
   assert(Util.Type.check_type(valitab,"<hc-func.config>.options",new_options))
  end,
  Util.ERROR
 )
 Config.current=new_options
end
return Config
