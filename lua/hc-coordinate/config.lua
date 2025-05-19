local Util=require("hc-nvim.util")
local Validate=Util.Validate
---@class Coordinate.config_manager
local Config={}
---@class Coordinate.config
Config.default={}
Config.current=Config.default
Config.options=Util.Reference.get(function() return Config.current end)
local valitab={}
--- Set options.
--- if opts is nil, reset to default options.
--- else, update opts into current options.
---@param opts Coordinate.config
function Config.setup(opts)
 local new_options=vim.tbl_deep_extend("force",Config.current,opts)
 Validate.validate_assert("<hc-substitute>.options",new_options,valitab)
 Config.current=new_options
end
function Config.fini()
 Config.current=Config.default
end
return Config
