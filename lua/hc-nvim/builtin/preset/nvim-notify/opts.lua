local Config=require("hc-nvim.config")
return {
 icons=require("hc-nvim.rsc").sign[Config.ui.sign],
 max_width=function() return math.ceil(0.4*vim.o.columns) end,
 max_height=function() return math.ceil(0.4*vim.o.lines) end,
 stages="fifo_plain",
 render="oneline",
 top_down=false,
}
