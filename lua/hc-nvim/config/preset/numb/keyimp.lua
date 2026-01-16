local numb=require("numb")
return {
 {
  name=NS.numb_toggle,
  rhs=function()
   local ok=pcall(function()
    vim.api.nvim_get_autocmds({group="numb"})
   end)
   if ok then
    numb.disable()
   else
    numb.setup()
   end
  end,
 },
}
