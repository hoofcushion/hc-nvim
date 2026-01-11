local Util=require("hc-nvim.util")
local function try(fn)
 xpcall(fn,function(err)
  vim.notify(err,vim.log.levels.ERROR)
 end)
end
local function find_assignment(node)
 local found=pcall(function()
  local proxy=Util.TSProxy.new(node)
  assert(node:child_count()==3,                                   "unbalanced-assignments")
  local var_list_node=proxy.variable_list()
  assert(var_list_node,                                           "nil var list")
  assert(var_list_node:child_count()==1,                          "zero var")
  local exp_list_node=proxy.expression_list()
  assert(exp_list_node,                                           "nil exp list")
  assert(exp_list_node:child_count()==1,                          "zero exp")
  assert(proxy.expression_list[1]():type()=="function_definition","function assignment")
  local funstr_node=proxy.expression_list.function_definition["function"]()
  assert(funstr_node)
 end)
 return found
end
local function switch(buf,win)
 buf=buf or vim.api.nvim_get_current_buf()
 win=win or vim.api.nvim_get_current_win()
 try(function()
  local cursor_node=Util.ts_get_cursor_node()
  assert(cursor_node,"cursor node not found")
  local assign_node=Util.ts_lookup(cursor_node,find_assignment)
  local declare_node=Util.ts_lookup(cursor_node,"function_declaration")
  if assign_node and declare_node then
   local cursor=vim.api.nvim_win_get_cursor(win)
   local pos={cursor[1]-1,cursor[2]}
   local assign_range={assign_node:range()}
   local a_distance=Util.ts_get_distance(pos,assign_range)
   local declare_range={declare_node:range()}
   local d_distance=Util.ts_get_distance(pos,declare_range)
   if a_distance<=d_distance then
    declare_node=nil
   else
    assign_node=nil
   end
  end
  if assign_node then
   try(function()
    local proxy=Util.TSProxy.new(assign_node)
    local var_node=proxy.variable_list[1]()
    assert(var_node,     "nil var")
    local exp_node=proxy.expression_list[1]()
    assert(exp_node,     "nil exp")
    local funstart_node=proxy.expression_list[1]["function"]()
    assert(funstart_node,"nil funstart")
    local funstart_range={funstart_node:range()}
    local var_range={var_node:range()}
    local repl_range={var_range[1],var_range[2],funstart_range[3],funstart_range[4]}
    local var_text=vim.treesitter.get_node_text(var_node,buf)
    local repl_text="function "..var_text
    Util.buf_set_text(buf,repl_range,repl_text)
   end)
  end
  if declare_node then
   try(function()
    local proxy=Util.TSProxy.new(declare_node)
    local name_node=proxy.name()
    assert(name_node,    "nil name")
    local funstart_node=proxy["function"]()
    assert(funstart_node,"nil funcstart")
    local funstart_range={funstart_node:range()}
    local name_range={name_node:range()}
    local repl_range={funstart_range[1],funstart_range[2],name_range[3],name_range[4]}
    local name_str=vim.treesitter.get_node_text(name_node,buf)
    local repl_text=("%s=function"):format(name_str)
    Util.buf_set_text(buf,repl_range,repl_text)
   end)
  end
 end)
end
return {
 switch=switch,
}
