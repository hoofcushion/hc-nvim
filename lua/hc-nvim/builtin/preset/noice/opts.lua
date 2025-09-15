local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.rsc")
---@module "noice"
---@type NoiceConfig|{}
return {
 cmdline={
  view="cmdline",
 },
 redirect={
  view="popup",
 },
 -- set refresh limit
 throttle=Config.performance.throttle,
 ---change all default commands view to popup
 ---@type table<string, NoiceCommand|{}>
 commands={
  history={view="popup"},
  last={view="popup"},
  errors={view="popup"},
  all={view="popup"},
 },
 ---@type NoiceConfigViews|{}
 views=vim.tbl_deep_extend(
  "force",
  -- set all border style
  (function()
   local ret={}
   for _,key in ipairs({
    "cmdline",
    "cmdline_input",
    "cmdline_output",
    "cmdline_popup",
    "cmdline_popupmenu",
    "confirm",
    "hover",
    "messages",
    "mini",
    "notify",
    "popup",
    "popupmenu",
    "split",
    "virtualtext",
    "vsplit",
   }) do
    ret[key]={
     border={
      style=Rsc.border[Config.ui.border],
     },
    }
   end
   return ret
  end)(),
  -- set window size
  {
   popup={size={height=Config.ui.window.percentage.height,width=Config.ui.window.percentage.width}},
   split={size=Config.ui.window.percentage.vertical},
   vsplit={size=Config.ui.window.percentage.horizontal},
  },
  -- fix cmdline border
  {cmdline={border={padding={0,-1}}}}
 ),
}
