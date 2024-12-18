local Config=require("hc-nvim.config")
return {
 cmdline={
  view="cmdline",
 },
 redirect={
  view="split",
 },
 lsp={
  documentation={
   opts={
    border=require("hc-nvim.rsc").border[Config.ui.border],
   },
  },
 },
 throttle=Config.performance.throttle,
 views={
  -- cmdline,
  -- cmdline_output,
  -- cmdline_popup,
  -- confirm,
  -- hover,
  -- messages,
  -- mini,
  -- notify,
  popup={
   size={
    height=Config.ui.window.percentage.height,
    width=Config.ui.window.percentage.width,
   },
  },
  -- popupmenu,,
  split={
   size=Config.ui.window.percentage.vertical,
  },
  vsplit={
   size=Config.ui.window.percentage.horizontal,
  },
 },
}
