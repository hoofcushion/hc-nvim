local Util=require("hc-nvim.util")
return Util.parse_override({
 override={event="User",pattern="LazyDone",once=true,buffer=false},
 wkspec={"<leader>L",group="Lazy"},
 {lhs="<leader>Ll",cmd="Lazy",        desc="Lazy Dashboard"},
 {lhs="<leader>Lp",cmd="Lazy profile",desc="Lazy Profile"},
 {lhs="<leader>Lu",cmd="Lazy update", desc="Lazy Update"},
})
