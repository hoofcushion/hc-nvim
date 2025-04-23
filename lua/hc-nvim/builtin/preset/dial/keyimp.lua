local dial=require("dial.map")
return {
 {name=NS.dial_increment,    rhs=function() dial.manipulate("increment","normal") end},
 {name=NS.dial_decrement,    rhs=function() dial.manipulate("decrement","normal") end},
 {name=NS.dial_increment_g,  rhs=function() dial.manipulate("increment","gnormal") end},
 {name=NS.dial_decrement_g,  rhs=function() dial.manipulate("decrement","gnormal") end},
 {name=NS.dial_increment_v,  rhs=function() dial.manipulate("increment","visual") end},
 {name=NS.dial_decrement_v,  rhs=function() dial.manipulate("decrement","visual") end},
 {name=NS.dial_increment_v_g,rhs=function() dial.manipulate("increment","gvisual") end},
 {name=NS.dial_decrement_v_g,rhs=function() dial.manipulate("decrement","gvisual") end},
}
