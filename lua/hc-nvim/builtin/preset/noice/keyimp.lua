local noice=require("noice")
local noice_lsp=require("noice.lsp")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.noice_history,    cmd="Noice history"},
 {name=NS.noice_last,       cmd="Noice last"},
 {name=NS.noice_dismiss,    cmd="Noice dismiss"},
 {name=NS.noice_errors,     cmd="Noice errors"},
 {name=NS.noice_stats,      cmd="Noice stats"},
 {name=NS.noice_telescope,  cmd="Noice telescope"},
 {name=NS.noice_disable,    cmd="Noice disable"},
 {name=NS.noice_enable,     cmd="Noice enable"},
 {name=NS.noice_redirect,   rhs=Wrapper.fn_eval(noice.redirect,vim.fn.getcmdline)},
 {name=NS.noice_scroll_up,  rhs=function() return noice_lsp.scroll(-4)end},
 {name=NS.noice_scroll_down,rhs=function() return noice_lsp.scroll(4)end},
}
