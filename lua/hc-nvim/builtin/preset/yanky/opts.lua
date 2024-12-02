local Config=require("hc-nvim.config")
return {
 ring={storage=Config.platform.is_windows and "shada" or"sqlite"},
 highlight={
  on_put=true,
  on_yank=true,
  timer=500,
 },
}
