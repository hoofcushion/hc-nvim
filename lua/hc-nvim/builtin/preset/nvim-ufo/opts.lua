local Config=require("hc-nvim.config")
return {
 preview={
  win_config={
   border=require("hc-nvim.rsc").border[Config.ui.border],
  },
 },
}
