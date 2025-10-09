local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.rsc")
local opts=vim.tbl_deep_extend(
 "force",
 {
  bigfile={enabled=true},
  dashboard={enabled=vim.fn.argc()==0},
  explorer={enabled=false},
  indent={enabled=true},
  input={enabled=true},
  picker={enabled=false},
  notifier={enabled=false},
  quickfile={enabled=false},
  scope={enabled=true},
  scroll={enabled=false},
  statuscolumn={enabled=false},
  words={enabled=false},
 },{

  dashboard={
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
  indent={
   indent={
    enabled=true,
    hl=require("hc-nvim.misc.rainbow").create(7,25,50),
   },
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
  notifier={
   icons=Rsc.sign[Config.ui.sign]:prefix(" "),
   style="minimal",
   top_down=false,
  },
 },
 {
  styles={
   input               ={
    border=Rsc.border[Config.ui.border],
    relative="cursor",
    row=-3,
    col=0,
   },
   snacks_image        ={border=Rsc.border[Config.ui.border]},
   scratch             ={border=Rsc.border[Config.ui.border]},
   notification_history={border=Rsc.border[Config.ui.border]},
   notification        ={border=Rsc.border[Config.ui.border]},
   blame_line          ={border=Rsc.border[Config.ui.border]},
   dashboard           ={border=Rsc.border[Config.ui.border]},
   float               ={border=Rsc.border[Config.ui.border]},
   minimal             ={border=Rsc.border[Config.ui.border]},
   split               ={border=Rsc.border[Config.ui.border]},
   help                ={border=Rsc.border[Config.ui.border]},
  },
 })
if Config.platform.is_vscode then
 opts=vim.tbl_deep_extend("force",opts,{
  bigfile={enabled=true},
  dashboard={enabled=false},
  explorer={enabled=false},
  indent={enabled=false},
  input={enabled=false},
  picker={enabled=false},
  notifier={enabled=false},
  quickfile={enabled=false},
  scope={enabled=false},
  scroll={enabled=false},
  statuscolumn={enabled=false},
  words={enabled=false},
 })
end
return opts
