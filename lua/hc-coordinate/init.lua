local M={}
function M.fini()
 require("hc-coordinate.config").fini()
 require("hc-coordinate.function").fini()
end
function M.setup(opts)
 require("hc-coordinate.config").setup(opts)
 require("hc-coordinate.function").setup()
end
return M
