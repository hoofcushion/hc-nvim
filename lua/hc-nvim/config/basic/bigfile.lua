local function augroup(name)
 return vim.api.nvim_create_augroup("HCNvim_"..name,{clear=true})
end
-- Automatically enter insert mode when open terminal

vim.api.nvim_create_autocmd("FileType",{
 pattern={"bigfile"},
 group=augroup("big_file_tweak"),
 callback=function(ev)
  vim.bo[ev.buf].filetype=""
  vim.treesitter.stop(ev.buf)
  vim.api.nvim_buf_call(ev.buf,function()
   vim.cmd("syntax off")
  end)
  local clients=vim.lsp.get_clients({buf=ev.buf})
  for _,client in ipairs(clients) do
   if client.attached_buffers[ev.buf] then
    vim.lsp.buf_detach_client(ev.buf,client.id)
   end
  end
  local winrs=vim.api.nvim_list_wins()
  for _,win in ipairs(winrs) do
   local buf=vim.api.nvim_win_get_buf(win)
   if buf==ev.buf then
    vim.wo[win].wrap=false
    vim.wo[win].spell=false
   end
  end
 end,
})
