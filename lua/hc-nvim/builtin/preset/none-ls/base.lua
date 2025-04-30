return {
 main="null-ls",
 dependencies={
  "plenary.nvim",
 },
 init=function(ev)
  vim.opt.rtp:append(ev.dir)
 end,
 config=true,
}
