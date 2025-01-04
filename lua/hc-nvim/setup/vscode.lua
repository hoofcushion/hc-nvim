if vim.g.vscode==nil then
 return
end
local Config=require("lazy.core.config")
Config.options.checker.enabled=false
Config.options.change_detection.enabled=false
if pcall(function() require("nvim-theme") end) then
 vim.api.nvim_command([[
  " THEME CHANGER
  function! SetCursorLineNrColorInsert(mode)
   " Insert mode: blue
   if a:mode == "i"
    call VSCodeNotify('nvim-theme.insert')

   " Replace mode: red
   elseif a:mode == "r"
    call VSCodeNotify('nvim-theme.replace')
   endif
  endfunction

  augroup CursorLineNrColorSwap
   autocmd!
   autocmd ModeChanged *:[vV\x16]* call VSCodeNotify('nvim-theme.visual')
   autocmd ModeChanged *:[R]* call VSCodeNotify('nvim-theme.replace')
   autocmd InsertEnter * call SetCursorLineNrColorInsert(v:insertmode)
   autocmd InsertLeave * call VSCodeNotify('nvim-theme.normal')
   autocmd CursorHold * call VSCodeNotify('nvim-theme.normal')
   autocmd ModeChanged [vV\x16]*:* call VSCodeNotify('nvim-theme.normal')
  augroup END
]])
end
