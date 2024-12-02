local substitute=require("hc-substitute")
return {
 {name=NS.hc_substitute_paste_eol,        rhs=substitute.paste_eol},
 {name=NS.hc_substitute_paste_line,       rhs=substitute.paste_line},
 {name=NS.hc_substitute_paste_op,         rhs=substitute.paste_op},
 {name=NS.hc_substitute_paste_visual,     rhs=substitute.paste_visual},
 {name=NS.hc_substitute_exchange_cancel,  rhs=substitute.exchange_cancel},
 {name=NS.hc_substitute_exchange_line,    rhs=substitute.exchange_line},
 {name=NS.hc_substitute_exchange_op,      rhs=substitute.exchange_op},
 {name=NS.hc_substitute_exchange_visual,  rhs=substitute.exchange_visual},
 {name=NS.hc_substitute_substitute_op,    rhs=substitute.substitute_op},
 {name=NS.hc_substitute_substitute_visual,rhs=substitute.substitute_visual},
}
