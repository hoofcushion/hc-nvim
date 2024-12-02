local spectre=require("spectre")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.nvim_spectre_toggle,          rhs=spectre.toggle},
 {name=NS.nvim_spectre_open_file_search,rhs=spectre.open_file_search},
 {name=NS.nvim_spectre_current_word,    rhs=Wrapper.fn(spectre.open_visual,{select_word=true})},
 {name=NS.nvim_spectre_open_visual,     rhs=spectre.open_visual},
}
