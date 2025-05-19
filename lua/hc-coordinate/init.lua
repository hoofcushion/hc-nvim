local M={}
function M.fini()
 require("hc-func.config").fini()
 require("hc-func.function").fini()
end
function M.setup(opts)
 require("hc-func.config").setup(opts)
 require("hc-func.function").setup()
end
return M
