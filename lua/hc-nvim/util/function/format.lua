local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
local LocalEnv=Util.LocalEnv.new()
local click=0
local format=vim.lsp.buf.format
--- @param opts? vim.lsp.buf.format.Opts
local function format_raw(opts)
 click=0
 if Config.platform.is_vscode then
  return vim.lsp.buf.format(opts)
 end
 opts=opts or {}
 local buf=opts.bufnr or vim.api.nvim_get_current_buf()
 local mode=vim.fn.mode()
 local is_visual_mode=mode:match("[vV]")~=nil
 local method=is_visual_mode and "textDocument/rangeFormatting" or "textDocument/formatting"
 local clients=vim.lsp.get_clients({
  bufnr=buf,
  method=method,
 })
 if #clients==0 then
  vim.notify("No LSP clients available for formatting",vim.log.levels.WARN)
  return
 end
 if #clients==1 then
  format(vim.tbl_extend("force",opts,{name=clients[1].name}))
  return
 end
 if LocalEnv.buffer.lsp_format_choice then
  local valid_choice=vim.lsp.get_clients({name=LocalEnv.buffer.lsp_format_choice})[1]~=nil
  if valid_choice then
   format(vim.tbl_extend("force",opts,{name=LocalEnv.buffer.lsp_format_choice}))
   return
  else
   LocalEnv.buffer.lsp_format_choice=nil
  end
 end
 Util.async(function()
  local choice=Util.await(function(resume)
   vim.ui.select(clients,{
    prompt="Select formatting client:",
    format_item=function(item)
     return string.format("%s (%s)",item.name,item.id)
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
local format_d=Util.debounce(200,vim.schedule_wrap(format_raw))
---@param opts? table Format options
---@return nil
local function format(opts)
 if not LocalEnv.buffer.lsp_format_choice then
  return format_raw(opts)
 end
 click=math.min(2,click+1)
 if click==2 then
  LocalEnv.buffer.lsp_format_choice=false
 end
 format_d(opts)
end

return format
