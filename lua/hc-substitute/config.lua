
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
  ---@type table<"v"|"V"|"",boolean>
  end_select={
   v=false,
   V=false,
   [""]=false,
  },
  highlight={
   enabled=true,
   blink_delay=500,
   hl_group="SubstituteBlink",
   hl_opts={link="Substitute"},
  },
 },
}
Config.current=Config.default
local Validate=require("hc-nvim.util.validate")
local valitab={
 command="boolean",
 paste={
  end_pos=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
 exchange={
  end_pos=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  end_mark=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  end_select={
   v="boolean",
   V="boolean",
   [""]="boolean",
  },
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
}
--- Set options.
--- if opts is nil, reset to default options.
--- else, update opts into current options.
---@param opts Substitute.config
function Config.setup(opts)
 local new_options=vim.tbl_deep_extend("force",Config.current,opts)
 Validate.validate_assert("<hc-substitute>.options",new_options,valitab)
 Config.current=new_options
end
function Config.fini()
 Config.current=Config.default
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
