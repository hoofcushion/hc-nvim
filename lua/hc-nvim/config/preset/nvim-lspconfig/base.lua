return {
 cmd={
  "LspInfo",
 },
 init=function(ev)
  vim.opt.rtp:append(ev.dir)
 end,
}
