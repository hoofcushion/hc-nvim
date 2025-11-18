local Util=require("hc-nvim.util")
local Spider=require("spider")
return {
 {name=NS.global_motion_ge,rhs=Util.Wrapper.fn_with(Spider.motion,"ge"),desc="Spider ge"},
 {name=NS.global_motion_b, rhs=Util.Wrapper.fn_with(Spider.motion,"b"), desc="Spider b"},
 {name=NS.global_motion_e, rhs=Util.Wrapper.fn_with(Spider.motion,"e"), desc="Spider e"},
 {name=NS.global_motion_w, rhs=Util.Wrapper.fn_with(Spider.motion,"w"), desc="Spider w"},
}
