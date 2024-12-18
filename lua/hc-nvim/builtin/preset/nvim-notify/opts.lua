local Config=require("hc-nvim.config")
return {
 icons=require("hc-nvim.rsc").sign[Config.ui.sign],
 max_width=Config.ui.window:dynamic("width",0.8),
 max_height=Config.ui.window:dynamic("width",0.8),
 stages="fifo_plain",
 render="oneline",
 top_down=false,
}
