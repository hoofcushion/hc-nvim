local todo_comments=require("todo-comments")
return {
 {name=NS.todo_comments_prev,         rhs=todo_comments.jump_prev},
 {name=NS.todo_comments_next,         rhs=todo_comments.jump_next},
 {name=NS.todo_comments_location_list,cmd="TodoLoclist"},
 {name=NS.todo_comments_quick_fix,    cmd="TodoQuickFix"},
 {name=NS.todo_comments_telescope,    cmd="TodoTelescope"},
 {name=NS.todo_comments_trouble,      cmd="TodoTrouble"},
}
