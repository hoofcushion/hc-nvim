local HCNvim=require("hc-nvim.init_space")
local LocalEnv=HCNvim.Util.LocalEnv.new()
local function format(...)
 return vim.lsp.buf.format(...)
end
--- 获取支持格式化的客户端列表
--- @param buf? number
--- @param is_range? boolean
--- @return table[]
local function get_format_clients(buf,is_range)
 buf=buf or vim.api.nvim_get_current_buf()
 local method=is_range and "textDocument/rangeFormatting" or "textDocument/formatting"
 return vim.lsp.get_clients({
  bufnr=buf,
  method=method,
 })
end
--- 检查保存的选择是否有效
--- @param clients table[]
--- @param saved_choice string|nil
--- @return boolean, string|nil
local function is_valid_choice(clients,saved_choice)
 if not saved_choice then
  return false,nil
 end
 for _,client in ipairs(clients) do
  if client.name==saved_choice then
   return true,saved_choice
  end
 end
 return false,nil
end
--- 带选择的格式化函数
--- @param opts? vim.lsp.buf.format.Opts
local function format_with_choice(opts,reset)
 opts=opts or {}
 local buf=opts.bufnr or vim.api.nvim_get_current_buf()
 local is_visual_mode=vim.fn.mode():match("[vV]")~=nil
 local clients=get_format_clients(buf,is_visual_mode)
 if #clients==0 then
  vim.notify("No LSP clients available for formatting",vim.log.levels.WARN)
  return
 end
 if #clients==1 then
  format(vim.tbl_extend("force",opts,{name=clients[1].name}))
  return
 end
 if not reset then
  -- 检查已有的选择是否有效
  local saved_choice=LocalEnv.buffer.lsp_format_choice
  local valid,choice_name=is_valid_choice(clients,saved_choice)
  if valid then
   format(vim.tbl_extend("force",opts,{name=choice_name}))
   return
  end
  -- 无效选择，清除
  if saved_choice then
   LocalEnv.buffer.lsp_format_choice=nil
  end
 end
 -- 弹出选择UI
 HCNvim.Util.async(function()
  local choice=HCNvim.Util.await(function(resume)
   vim.ui.select(clients,{
    prompt="Select formatting client:",
    format_item=function(client)
     return string.format("%s (%s)",client.name,client.id)
    end,
   },resume)
  end)
  if not choice then
   return
  end
  LocalEnv.buffer.lsp_format_choice=choice.name
  format(vim.tbl_extend("force",opts,{name=choice.name}))
 end)
end
local timer
local count=0
--- 双击重置选择的格式化函数
--- @param opts? vim.lsp.buf.format.Opts
--- @return nil
local function format_double_click(opts)
 timer=timer or assert(vim.uv.new_timer())
 count=count+1
 if count<2 then
  timer:start(175,0,vim.schedule_wrap(function()
   format_with_choice(opts,false)
   count=0
  end))
 else
  timer:stop()
  format_with_choice(opts,true)
  count=0
 end
end
-- 保持和原始函数相同的API
return format_double_click
