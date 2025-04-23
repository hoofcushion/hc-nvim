local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.rsc")
if vim.env.PROF then
 local snacks=vim.fn.stdpath("data").."/lazy/snacks.nvim"
 vim.opt.rtp:append(snacks)
 require("snacks.profiler").startup({
  startup={
   event="SafeState",
  },
 })
end
local opts={
 bigfile={enabled=true},
 dashboard={
  enabled=vim.fn.argc()==0,
  preset={

   header=(function()
    if Config.locale.current.language=="zh" then
     return require("hc-nvim.rsc.header")
    end
   end)(),

  },
  sections={
   {section="header"},
   {section="keys",gap=1},
   {gap=1},
   {icon=" ",title="Recent Files",section="recent_files",indent=1,padding=2},
   {icon=" ",title="Projects",section="projects",indent=1,padding=2},
   {section="startup"},
  },
 },
 image={enabled=true},
 indent={
  indent={
   enabled=true, -- enable indent guides
   hl=require("hc-nvim.misc.rainbow").create(7,25,50),
  },
  animate={
   enabled=false,
  },
  ---@class snacks.indent.Scope.Config: snacks.scope.Config
  scope={
   enabled=true,
   hl=require("hc-nvim.misc.rainbow").create(7,25,50),
  },
  chunk={
   enabled=true,
   hl=require("hc-nvim.misc.rainbow").create(7,25,50),

   char={
    corner_top="┌",
    corner_bottom="└",
    horizontal="─",
    vertical="│",
    arrow="",
   },
  },
 },
 input={enabled=true},
 picker={enabled=true},
 notifier={
  enabled=true,
  icons=Rsc.sign[Config.ui.sign]:prefix(" "),
  style="minimal",
  top_down=false,
 },
 profiler={enabled=true},
 scope={enabled=true},
 styles={
  blame_line={border=Rsc.border[Config.ui.border]},
  input={border=Rsc.border[Config.ui.border]},
  notification={border=Rsc.border[Config.ui.border]},
  notification_history={border=Rsc.border[Config.ui.border]},
  scratch={border=Rsc.border[Config.ui.border]},
  snacks_image={border=Rsc.border[Config.ui.border]},
 },
}
if Config.platform.is_vscode then
 opts=vim.tbl_deep_extend("force",opts,{
  dashboard={enabled=false},
  indent={enabled=false},
  image={enabled=false},
  input={enabled=false},
  picker={enabled=false},
  notifier={enabled=false},
  profiler={enabled=false},
 })
end
return opts
