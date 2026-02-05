local HCNvim=require("hc-nvim.init_space")
local function try(fn)
 xpcall(fn,function(err)
  vim.notify(err,vim.log.levels.ERROR)
 end)
end

local function switch_oop(buf,win)
 buf=buf or vim.api.nvim_get_current_buf()
 win=win or vim.api.nvim_get_current_win()
 try(function()
  local method_node,dot_node
  do
   local cursor_node=HCNvim.Util.ts_get_cursor_node()
   assert(cursor_node,"cursor node not found")
   -- 查找函数声明节点
   local func_node=HCNvim.Util.ts_lookup(cursor_node,"function_declaration")
   assert(func_node,"function_declaration")
   local proxy=HCNvim.Util.TSProxy.new(func_node)
   local name_node=proxy.name()
   assert(name_node,"name")
   -- 根据函数名节点类型区分两种模式
   if name_node:type()=="method_index_expression" then
    method_node=func_node
   elseif name_node:type()=="dot_index_expression" then
    dot_node=func_node
   end
  end
  assert(method_node or dot_node,"no method or dot function declaration found")
  if method_node then
   try(function()
    local proxy=HCNvim.Util.TSProxy.new(method_node)
    local name_node=proxy.name()
    assert(name_node,"nil name")
    -- 解析方法调用：table:method
    local table_node=name_node:field("table")[1]
    local method_node_name=name_node:field("method")[1]
    assert(table_node and method_node_name,"invalid method syntax")
    local table_text=vim.treesitter.get_node_text(table_node,buf)
    local method_text=vim.treesitter.get_node_text(method_node_name,buf)
    -- 初始化空参数列表
    local params_text="()"
    -- 获取参数节点
    local params_node=proxy.parameters()
    assert(params_node,"parameters node")
    -- 获取原参数字串
    local text=vim.treesitter.get_node_text(params_node,buf)
    if text~=params_text then
     params_text=text
    end
    -- 检测参数间隔
    local sep=string.match(params_text,",(%s+)") or ""
    -- 构建带 self, 的新参数字串
    params_text="(".."self,"..sep..string.sub(params_text,2,-2)..")"
    -- 替换原本的参数签名
    local func_start_node=proxy["function"]()
    assert(func_start_node,"nil funcstart")
    local func_start_range={func_start_node:range()}
    local params_range={params_node:range()}
    local repl_range={func_start_range[1],func_start_range[2],params_range[3],params_range[4]}
    local repl_text=table.concat({"function"," ",table_text,".",method_text,params_text})
    HCNvim.Util.buf_set_text(buf,repl_range,repl_text)
   end)
  end
  if dot_node then
   try(function()
    local proxy=HCNvim.Util.TSProxy.new(dot_node)
    local name_node=proxy.name()
    assert(name_node,"nil name")
    -- 解析点调用：table.method
    local table_node=name_node:field("table")[1]
    local field_node=name_node:field("field")[1]
    assert(table_node and field_node,"invalid dot syntax")
    local table_text=vim.treesitter.get_node_text(table_node,buf)
    local field_text=vim.treesitter.get_node_text(field_node,buf)
    -- 获取参数节点
    local params_node=proxy.parameters()
    assert(params_node,"parameters node")
    -- 获取原参数字串
    local params_text=vim.treesitter.get_node_text(params_node,buf)
    -- 移除self参数
    if params_text:match("^%s*%(%s*self%s*,%s*") then
     -- 有self参数，移除它
     params_text=params_text:gsub("^%s*%(%s*self%s*,%s*","(")
    elseif params_text:match("^%s*%(%s*self%s*%)") then
     -- 只有self参数，转为空参数
     params_text="()"
    end
    -- 替换原本的参数签名
    local func_start_node=proxy["function"]()
    assert(func_start_node,"nil funcstart")
    local func_start_range={func_start_node:range()}
    local params_range={params_node:range()}
    local repl_range={func_start_range[1],func_start_range[2],params_range[3],params_range[4]}
    local repl_text=table.concat({"function"," ",table_text,":",field_text,params_text})
    HCNvim.Util.buf_set_text(buf,repl_range,repl_text)
   end)
  end
 end)
end
switch_oop()
return {
 switch=switch_oop,
}
