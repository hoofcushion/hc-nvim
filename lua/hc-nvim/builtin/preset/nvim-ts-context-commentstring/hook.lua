return {
 {
  {"Comment.nvim","nvim-ts-context-commentstring"},
  function()
   local opts={
    pre_hook=require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
   }
   require("Comment").setup(opts)
  end,
 },
}
