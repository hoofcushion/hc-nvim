local neotree_command=require("neo-tree.command")
local execute=neotree_command.execute
return {
 {name=NS.neotree_action_close,          rhs=function() execute({action="close"}) end},
 {name=NS.neotree_action_focus,          rhs=function() execute({action="focus"}) end},
 {name=NS.neotree_action_show,           rhs=function() execute({action="show"}) end},
 {name=NS.neotree_filesystem_current_dir,rhs=function() execute({source="filesystem",dir=vim.fn.expand("%:h")}) end},
 {name=NS.neotree_filesystem_vim_cwd,    rhs=function() execute({source="filesystem",dir=vim.fn.getcwd()}) end},
 {name=NS.neotree_filesystem_env_pwd,    rhs=function() execute({source="filesystem",dir=vim.env.PWD}) end},
 {name=NS.neotree_filesystem_root,       rhs=function() execute({source="filesystem",dir=vim.fs.normalize("/")}) end},
 {name=NS.neotree_reveal,                rhs=function() execute({reveal=true}) end},
 {name=NS.neotree_show_buffers,          rhs=function() execute({action="show",source="buffers"}) end},
 {name=NS.neotree_show_filesystem,       rhs=function() execute({action="show",source="filesystem"}) end},
 {name=NS.neotree_show_git,              rhs=function() execute({action="show",source="git_status"}) end},
 {name=NS.neotree_toggle,                rhs=function() execute({toggle=true}) end},
}
