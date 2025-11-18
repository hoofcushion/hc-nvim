local Config=require("hc-nvim.config")
return {
 hint="floating-big-letter",
 filter_rules={
  include_current_win=false,
  autoselect_one=true,
  bo={
   filetype=Config.performance.exclude.filetypes,
   buftype=Config.performance.exclude.buftypes,
  },
 },
}
