-- lua/hc-nvim/config/preset/nvim-treesitter-textobjects/keyimp.lua

local select=require("nvim-treesitter-textobjects.select")
local move=require("nvim-treesitter-textobjects.move")
return {
 -- Select
 {name=NS.ts_select_assignment_lhs,   rhs=function() select.select_textobject("@assignment.lhs","textobjects") end},
 {name=NS.ts_select_assignment_rhs,   rhs=function() select.select_textobject("@assignment.rhs","textobjects") end},
 {name=NS.ts_select_assignment_outer, rhs=function() select.select_textobject("@assignment.outer","textobjects") end},
 {name=NS.ts_select_assignment_inner, rhs=function() select.select_textobject("@assignment.inner","textobjects") end},
 {name=NS.ts_select_attribute_outer,  rhs=function() select.select_textobject("@attribute.outer","textobjects") end},
 {name=NS.ts_select_attribute_inner,  rhs=function() select.select_textobject("@attribute.inner","textobjects") end},
 {name=NS.ts_select_block_outer,      rhs=function() select.select_textobject("@block.outer","textobjects") end},
 {name=NS.ts_select_block_inner,      rhs=function() select.select_textobject("@block.inner","textobjects") end},
 {name=NS.ts_select_call_outer,       rhs=function() select.select_textobject("@call.outer","textobjects") end},
 {name=NS.ts_select_call_inner,       rhs=function() select.select_textobject("@call.inner","textobjects") end},
 {name=NS.ts_select_class_outer,      rhs=function() select.select_textobject("@class.outer","textobjects") end},
 {name=NS.ts_select_class_inner,      rhs=function() select.select_textobject("@class.inner","textobjects") end},
 {name=NS.ts_select_comment_outer,    rhs=function() select.select_textobject("@comment.outer","textobjects") end},
 {name=NS.ts_select_comment_inner,    rhs=function() select.select_textobject("@comment.inner","textobjects") end},
 {name=NS.ts_select_conditional_outer,rhs=function() select.select_textobject("@conditional.outer","textobjects") end},
 {name=NS.ts_select_conditional_inner,rhs=function() select.select_textobject("@conditional.inner","textobjects") end},
 {name=NS.ts_select_frame_outer,      rhs=function() select.select_textobject("@frame.outer","textobjects") end},
 {name=NS.ts_select_frame_inner,      rhs=function() select.select_textobject("@frame.inner","textobjects") end},
 {name=NS.ts_select_function_outer,   rhs=function() select.select_textobject("@function.outer","textobjects") end},
 {name=NS.ts_select_function_inner,   rhs=function() select.select_textobject("@function.inner","textobjects") end},
 {name=NS.ts_select_loop_outer,       rhs=function() select.select_textobject("@loop.outer","textobjects") end},
 {name=NS.ts_select_loop_inner,       rhs=function() select.select_textobject("@loop.inner","textobjects") end},
 {name=NS.ts_select_number_inner,     rhs=function() select.select_textobject("@number.inner","textobjects") end},
 {name=NS.ts_select_parameter_outer,  rhs=function() select.select_textobject("@parameter.outer","textobjects") end},
 {name=NS.ts_select_parameter_inner,  rhs=function() select.select_textobject("@parameter.inner","textobjects") end},
 {name=NS.ts_select_regex_outer,      rhs=function() select.select_textobject("@regex.outer","textobjects") end},
 {name=NS.ts_select_regex_inner,      rhs=function() select.select_textobject("@regex.inner","textobjects") end},
 {name=NS.ts_select_return_outer,     rhs=function() select.select_textobject("@return.outer","textobjects") end},
 {name=NS.ts_select_return_inner,     rhs=function() select.select_textobject("@return.inner","textobjects") end},
 {name=NS.ts_select_scopename_inner,  rhs=function() select.select_textobject("@scopename.inner","textobjects") end},
 {name=NS.ts_select_statement_outer,  rhs=function() select.select_textobject("@statement.outer","textobjects") end},

 -- Move next
 {name=NS.ts_move_next_function,      rhs=function() move.goto_next_start("@function.outer","textobjects") end},
 {name=NS.ts_move_next_class,         rhs=function() move.goto_next_start("@class.outer","textobjects") end},
 {name=NS.ts_move_next_scope,         rhs=function() move.goto_next_start("@local.scope","locals") end},
 {name=NS.ts_move_next_parameter,     rhs=function() move.goto_next_start("@parameter.outer","textobjects") end},
 {name=NS.ts_move_next_comment,       rhs=function() move.goto_next_start("@comment.outer","textobjects") end},
 {name=NS.ts_move_next_conditional,   rhs=function() move.goto_next_start("@conditional.outer","textobjects") end},
 {name=NS.ts_move_next_fold,          rhs=function() move.goto_next_start("@fold","folds") end},

 -- Move prev
 {name=NS.ts_move_prev_function,      rhs=function() move.goto_previous_start("@function.outer","textobjects") end},
 {name=NS.ts_move_prev_class,         rhs=function() move.goto_previous_start("@class.outer","textobjects") end},
 {name=NS.ts_move_prev_scope,         rhs=function() move.goto_previous_start("@local.scope","locals") end},
 {name=NS.ts_move_prev_parameter,     rhs=function() move.goto_previous_start("@parameter.outer","textobjects") end},
 {name=NS.ts_move_prev_comment,       rhs=function() move.goto_previous_start("@comment.outer","textobjects") end},
 {name=NS.ts_move_prev_conditional,   rhs=function() move.goto_previous_start("@conditional.outer","textobjects") end},
 {name=NS.ts_move_prev_fold,          rhs=function() move.goto_previous_start("@fold","folds") end},
}
