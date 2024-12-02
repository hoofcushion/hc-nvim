local Config=require("hc-nvim.config")
return {
 signcolumn=true,
 numhl=true,
 linehl=false,
 word_diff=false,
 watch_gitdir={
  follow_files=true,
 },
 auto_attach=true,
 attach_to_untracked=true,
 current_line_blame=true,
 preview_config={border=require("hc-nvim.rsc").border[Config.ui.border]},
 on_attach=(function()
  local mapping=require("hc-nvim.setup.mapping"):export("gitsigns")
  return function(bufnr)
   mapping:create(bufnr)
  end
 end)(),
}
