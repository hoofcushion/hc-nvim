local iswap=require("iswap")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.iswap,                rhs=iswap.iswap},
 {name=NS.iswap_with,           rhs=iswap.iswap_with},
 {name=NS.iswap_with_right,     rhs=Wrapper.fn_with(iswap.iswap_with,"right")},
 {name=NS.iswap_with_left,      rhs=Wrapper.fn_with(iswap.iswap_with,"left")},
 {name=NS.imove,                rhs=iswap.imove},
 {name=NS.imove_with,           rhs=iswap.imove_with},
 {name=NS.imove_with_right,     rhs=Wrapper.fn_with(iswap.imove_with,"right")},
 {name=NS.imove_with_left,      rhs=Wrapper.fn_with(iswap.imove_with,"left")},
 {name=NS.iswap_node,           rhs=iswap.iswap_node},
 {name=NS.iswap_node_with,      rhs=iswap.iswap_node_with},
 {name=NS.iswap_node_with_right,rhs=Wrapper.fn_with(iswap.iswap_node_with,"right")},
 {name=NS.iswap_node_with_left, rhs=Wrapper.fn_with(iswap.iswap_node_with,"left")},
 {name=NS.imove_node,           rhs=iswap.imove_node},
 {name=NS.imove_node_with,      rhs=iswap.imove_node_with},
 {name=NS.imove_node_with_right,rhs=Wrapper.fn_with(iswap.imove_node_with,"right")},
 {name=NS.imove_node_with_left, rhs=Wrapper.fn_with(iswap.imove_node_with,"left")},
}
