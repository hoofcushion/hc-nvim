local Config=require("hc-nvim.config")
return {
 cmdline={
  enabled=true,
  view="cmdline",
 },
 messages={
  enabled=true,
 },
 popupmenu={
  enabled=true,
 },
 redirect={
  view="split",
 },
 notify={
  enabled=true,
 },
 lsp={
  progress={
   enabled=true,
   throttle=Config.performance.throttle,
   view="notify",
  },
  override={
   ["vim.lsp.util.convert_input_to_markdown_lines"]=true,
   ["vim.lsp.util.stylize_markdown"]=true,
   ["cmp.entry.get_documentation"]=true,
  },
  hover={
   enabled=true,
  },
  signature={
   enabled=true,
   auto_open={
    throttle=Config.performance.throttle,
   },
  },
  message={
   enabled=true,
  },
  documentation={
   opts={
    border=require("hc-nvim.rsc").border[Config.ui.border],
   },
  },
 },
 health={
  checker=true,
 },
 throttle=Config.performance.throttle,
}
