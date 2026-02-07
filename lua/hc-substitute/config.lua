local HCNvim=require("hc-nvim.init_space")
local Type=HCNvim.Util.Type
---@class Substitute.config_manager
local Config={}
---@class Substitute.config
Config.default={
 command=false,
 ---@class Substitute.config.paste
 paste={
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_pos="cursor_s",
  highlight={
   enabled=true,
   blink_delay=500,
   hl_group="SubstituteBlink",
   hl_opts={link="Substitute"},
  },
 },
 ---@class Substitute.config.exchange
 exchange={
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_pos="cursor_e",
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_mark="finish",
  ---@type table<"v"|"V"|"\22",boolean>
  end_select={
   v=false,
   V=false,
   ["\22"]=false,
  },
  highlight={
   enabled=true,
   blink_delay=500,
   hl_group="SubstituteBlink",
   hl_opts={link="Substitute"},
  },
 },
}
local valitab={
 command="boolean",
 paste={
  end_pos=Type.any({"start","finish","cursor_s","cursor_e"}),
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
 exchange={
  end_pos=Type.any({"start","finish","cursor_s","cursor_e"}),
  end_mark=Type.any({"start","finish","cursor_s","cursor_e"}),
  end_select={
   v="boolean",
   V="boolean",
   ["\22"]="boolean",
  },
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
}
if UnitTest then
 UnitTest:add_case({name="hc-substitute",expect=true,test=function() return Type.check_type(valitab,"config",Config.default) end})
end
Config.current=Config.default
Config.options=HCNvim.Util.Reference.get(function() return Config.current end)
function Config.fini()
 Config.current=Config.default
end
function Config.setup(opts)
 local new_options=vim.tbl_deep_extend("force",Config.current,opts)
 HCNvim.Util.try(
  function()
   assert(Type.check_type(valitab,"<hc-substitute.config>.options",new_options))
  end,
  HCNvim.Util.ERROR
 )
 Config.current=new_options
end
---@generic T
---@param default T
---@param opts table?
---@return T
function Config.get(default,opts)
 opts=(opts~=nil
  and vim.tbl_deep_extend("force",default,opts)
  or default)
 return opts
end
return Config
