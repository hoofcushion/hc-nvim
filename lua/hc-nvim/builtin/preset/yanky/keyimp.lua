local yanky=require("yanky")
return {
 {name=NS.yanky_put_after,                    rhs="<Plug>(YankyPutAfter)"},
 {name=NS.yanky_put_before,                   rhs="<Plug>(YankyPutBefore)"},
 {name=NS.yanky_g_put_after,                  rhs="<Plug>(YankyGPutAfter)"},
 {name=NS.yanky_g_put_before,                 rhs="<Plug>(YankyGPutBefore)"},
 {name=NS.yanky_previous_entry,               rhs=function() return yanky.can_cycle() and yanky.cycle(1) end},
 {name=NS.yanky_next_entry,                   rhs=function() return yanky.can_cycle() and yanky.cycle(-1) end},
 {name=NS.yanky_put_indent_after_linewise,    rhs="<Plug>(YankyPutIndentAfterLinewise)"},
 {name=NS.yanky_put_indent_before_linewise,   rhs="<Plug>(YankyPutIndentBeforeLinewise)"},
 {name=NS.yanky_put_indent_after_linewise,    rhs="<Plug>(YankyPutIndentAfterLinewise)"},
 {name=NS.yanky_put_indent_before_linewise,   rhs="<Plug>(YankyPutIndentBeforeLinewise)"},
 {name=NS.yanky_put_indent_after_shift_right, rhs="<Plug>(YankyPutIndentAfterShiftRight)"},
 {name=NS.yanky_put_indent_after_shift_right, rhs="<Plug>(YankyPutIndentAfterShiftRight)"},
 {name=NS.yanky_put_indent_after_shift_left,  rhs="<Plug>(YankyPutIndentAfterShiftLeft)"},
 {name=NS.yanky_put_indent_before_shift_right,rhs="<Plug>(YankyPutIndentBeforeShiftRight)"},
 {name=NS.yanky_put_indent_before_shift_left, rhs="<Plug>(YankyPutIndentBeforeShiftLeft)"},
 {name=NS.yanky_put_after_filter,             rhs="<Plug>(YankyPutAfterFilter)"},
 {name=NS.yanky_put_before_filter,            rhs="<Plug>(YankyPutBeforeFilter)"},
}
