local M={}
M.Config=require("hc-nvim.config")
M.Util=require("hc-nvim.util")
function M.setup()
 HCNvim=M
 require("hc-nvim.setup")
end
function M.export()
 return require("hc-nvim.setup.lazy")
end
return M
