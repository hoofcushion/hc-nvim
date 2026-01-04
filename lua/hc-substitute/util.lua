local Util={}
function Util.feedkeys(keys,mode)
 vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys,true,false,true),mode,false)
end
return Util
