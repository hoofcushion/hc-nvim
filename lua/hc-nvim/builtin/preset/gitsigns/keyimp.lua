local gitsigns=require("gitsigns")
return {
 {name=NS.gitsigns_next_hunk,                rhs=gitsigns.next_hunk},
 {name=NS.gitsigns_prev_hunk,                rhs=gitsigns.prev_hunk},
 {name=NS.gitsigns_reset_hunk,               rhs=gitsigns.reset_hunk},
 {name=NS.gitsigns_preview_hunk,             rhs=gitsigns.preview_hunk},
 {name=NS.gitsigns_blame_line,               rhs=gitsigns.blame_line},
 {name=NS.gitsigns_toggle_deleted,           rhs=gitsigns.toggle_deleted},
 {name=NS.gitsigns_toggle_current_line_blame,rhs=gitsigns.toggle_current_line_blame},
 {name=NS.gitsigns_toggle_linehl,            rhs=gitsigns.toggle_linehl},
 {name=NS.gitsigns_toggle_numhl,             rhs=gitsigns.toggle_numhl},
 {name=NS.gitsigns_toggle_signs,             rhs=gitsigns.toggle_signs},
}
