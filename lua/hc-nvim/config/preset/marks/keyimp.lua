local marks=require("marks")
return {
 {name=NS.marks_set,          rhs=marks.set},
 {name=NS.marks_set_next,     rhs=marks.set_next},
 {name=NS.marks_toggle,       rhs=marks.toggle},
 {name=NS.marks_next,         rhs=marks.next},
 {name=NS.marks_prev,         rhs=marks.prev},
 {name=NS.marks_preview,      rhs=marks.preview},
 {name=NS.marks_next_bookmark,rhs=marks.next_bookmark},
 {name=NS.marks_prev_bookmark,rhs=marks.prev_bookmark},
 {name=NS.marks_delete,       rhs=marks.delete},
 {name=NS.marks_delete_line,  rhs=marks.delete_line},
 {name=NS.marks_delete_buf,   rhs=marks.delete_buf},
 {name=NS.marks_annotate,     rhs=marks.annotate},
 {name=NS.marks_toggle_signs, rhs=marks.toggle_signs},
}
