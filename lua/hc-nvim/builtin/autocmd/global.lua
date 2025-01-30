-- This file is automatically loaded by lazyvim.config.init.
local function augroup(name)
 return vim.api.nvim_create_augroup("HCNvim_"..name,{clear=true})
end
-- Automatically enter insert mode when open terminal

vim.api.nvim_create_autocmd("TermOpen",{
 group=augroup("ternimal_auto_insert"),
 callback=function(event)
  local id=vim.api.nvim_create_autocmd("TermEnter",{
   buffer=event.buf,
   callback=function(_)
    vim.cmd.startinsert()
   end,
  })
  vim.api.nvim_create_autocmd("BufDelete",{
   once=true,
   buffer=event.buf,
   callback=function()
    vim.api.nvim_del_autocmd(id)
   end,
  })
 end,
})
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({"FocusGained","TermClose","TermLeave"},{
 group=augroup("checktime"),
 callback=function(ev)
  if ev.file~="" then
   vim.cmd("checktime")
  end
 end,
})
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost",{
 group=augroup("highlight_yank"),
 callback=function()
  vim.highlight.on_yank({higroup="IncSearch"})
 end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd("VimResized",{
 group=augroup("resize_splits"),
 callback=function()
  local current_tab=vim.fn.tabpagenr()
  vim.cmd("tabdo wincmd =")
  vim.cmd("tabnext "..current_tab)
 end,
})
-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost",{
 group=augroup("last_loc"),
 callback=function(event)
  local buf=event.buf
  local mark=vim.api.nvim_buf_get_mark(buf,'"')
  local lcount=vim.api.nvim_buf_line_count(buf)
  if mark[1]>0 and mark[1]<=lcount then
   pcall(vim.api.nvim_win_set_cursor,0,mark)
  end
 end,
})
-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType",{
 group=augroup("wrap_spell"),
 pattern={"text","plaintex","typst","gitcommit","markdown"},
 callback=function()
  vim.opt_local.wrap=true
  vim.opt_local.spell=true
 end,
})
-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({"FileType"},{
 group=augroup("json_conceal"),
 pattern="json*",
 callback=function()
  vim.opt_local.conceallevel=0
 end,
})
vim.api.nvim_create_autocmd({"BufWritePre"},{
 group=augroup("auto_create_dir"),
 callback=function(event)
  vim.fn.mkdir(vim.fn.fnamemodify(event.match,":p:h"),"p")
 end,
})
