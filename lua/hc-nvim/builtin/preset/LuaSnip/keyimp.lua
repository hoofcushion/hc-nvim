local luasnip=require("luasnip")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.luasnip_expand,       rhs=luasnip.expand},
 {name=NS.luasnip_jump_next,    rhs=Wrapper.fn(luasnip.jump,1)},
 {name=NS.luasnip_jump_prev,    rhs=Wrapper.fn(luasnip.jump,-1)},
 {name=NS.luasnip_change_choice,rhs=Wrapper.fn(luasnip.change_choice,1)},
}
