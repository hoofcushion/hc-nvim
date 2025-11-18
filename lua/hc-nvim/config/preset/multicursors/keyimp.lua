local multicursors=require("multicursors")
return {
 {name=NS.multicursors_word,           rhs=multicursors.start},
 {name=NS.multicursors_undercursor,    rhs=multicursors.new_under_cursor},
 {name=NS.multicursors_pattern,        rhs=multicursors.new_pattern},
 {name=NS.multicursors_visualselection,rhs=multicursors.search_visual},
 {name=NS.multicursors_visualpattern,  rhs=multicursors.new_pattern_visual},
}
