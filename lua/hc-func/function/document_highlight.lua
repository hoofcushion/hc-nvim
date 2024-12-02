local Config=require("hc-func.config")
local Util=require("hc-func.util")
local Options=Config.options.document_highlight
local DocHLAu=Util.Autocmd.new()
local Timer=Util.Timer.new()
local method="textDocument/documentHighlight"
local is_doc_hl={
 LspReferenceText=true,
 LspReferenceRead=true,
 LspReferenceWrite=true,
}
---@param extmark vim.api.keyset.get_extmark_item
---@param row integer
---@param col integer
local function pos_has_extmark(extmark,row,col)
 return
  row>=extmark[2] and
  col>=extmark[3] and
  row<=extmark[4].end_row and
  col<=extmark[4].end_col
end
local function cursor_has_doc_hl()
 local pos=vim.api.nvim_win_get_cursor(0)
 local row,col=pos[1]-1,pos[2]
 local extmarks=vim.api.nvim_buf_get_extmarks(0,-1,{row,0},{row,-1},{details=true})
 for _,extmark in ipairs(extmarks) do
  if is_doc_hl[extmark[4].hl_group] and pos_has_extmark(extmark,row,col) then
   return true
  end
 end
 return false
end
local function set_doc_hl()
 if cursor_has_doc_hl() then
  return
 end
 if next(vim.lsp.get_clients({bufnr=0,method=method}))==nil then
  return
 end
 vim.lsp.buf.clear_references()
 vim.lsp.buf.document_highlight()
end
set_doc_hl=vim.schedule_wrap(set_doc_hl)
local M={}
function M.activate()
 DocHLAu:activate()
end
function M.deactivate()
 DocHLAu:deactivate()
end
function M.enable()
 local event=Options.autocmd.enter
 local callback
 if Options.timer.enabled==true then
  local timer=Timer:new_timer()
  local landing,delay=Options.timer.landing,Options.timer.delay
  callback=function()
   if timer:is_active() then
    timer:start(landing,0,set_doc_hl)
    return
   end
   timer:start(delay,0,set_doc_hl)
  end
 else
  callback=set_doc_hl
 end
 DocHLAu:add({{event,{callback=callback}}})
 DocHLAu:add({{Options.autocmd.clear,{callback=vim.lsp.buf.clear_references}}})
 DocHLAu:create()
end
function M.disable()
 DocHLAu:fini()
end
return M
