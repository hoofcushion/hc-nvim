local M={}
M.Config=require("hc-nvim.config")
M.Util=require("hc-nvim.util")
M.Rsc=require("hc-nvim.rsc")
function M.setup()
 require("hc-nvim.setup")
end
function M.export()
 return require("hc-nvim.setup.lazy")
end
return M
