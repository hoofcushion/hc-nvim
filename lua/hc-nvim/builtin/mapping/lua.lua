local Util=require("hc-nvim.util")
return Util.parse_override({
 override={pattern="lua"},
 {lhs="<leader>luf",cmd="luafile %",            desc="Luafile %"},
 {lhs="<leader>lun",cmd="!nvim --headless -l %",desc="Nvim run %"},
 {lhs="<leader>lua",cmd="!lua %",               desc="!lua %"},
 {lhs="<leader>luj",cmd="!luajit %",            desc="!luajit %"},
})
