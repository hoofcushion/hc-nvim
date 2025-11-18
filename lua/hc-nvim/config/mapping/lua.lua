local Util=require("hc-nvim.util")
return Util.parse_override({
 override={pattern="lua"},
 {lhs="<leader>luf",cmd="luafile %",            desc="Luafile %"},
 {lhs="<leader>lun",cmd="!nvim --headless -l %",desc="Nvim run %"},
 {lhs="<leader>lua",cmd="!lua %",               desc="!lua %"},
 {lhs="<leader>luj",cmd="!luajit %",            desc="!luajit %"},
 {
  lhs="<leader>lut",
  rhs=function()
   local ts_utils=require("nvim-treesitter.ts_utils")
   local node=ts_utils.get_node_at_cursor()
   if not node then
    return
   end
   -- 查找赋值表达式: a.x=function()end
   while node and node:type()~="assignment_statement" do
    node=node:parent()
   end
   if not node then return end
   local children={}
   for child in node:iter_children() do
    table.insert(children,child)
   end
   if #children<3 then return end
   local var_node,func_node=children[1],children[3]
   if func_node:type()~="function_definition" then return end
   -- 提取变量名和函数体
   local var_range={var_node:range()}
   local func_range={func_node:range()}
   local buf=vim.api.nvim_get_current_buf()
   local var_text=vim.api.nvim_buf_get_text(buf,var_range[1],var_range[2],var_range[3],var_range[4],{})
   local func_text=vim.api.nvim_buf_get_text(buf,func_range[1],func_range[2],func_range[3],func_range[4],{})
   -- 构建新函数定义
   local new_func="function "..var_text[1]..table.concat(func_text,"\n",2)
   vim.api.nvim_buf_set_text(buf,var_range[1],var_range[2],func_range[3],func_range[4],vim.split(new_func,"\n"))
  end,
  desc="convert field to function",
 },
})
