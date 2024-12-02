local numb=require("numb")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.numb_toggle,rhs=Wrapper.fn_seq(numb.disable,numb.setup)},
}
