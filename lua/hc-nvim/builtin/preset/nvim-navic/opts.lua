return {
 icons=require("hc-nvim.rsc").kind[require("hc-nvim.config").ui.kind]:suffix(" "),
 click=true,
 highlight=true,
 lazy_update_context=true,
 lsp={
  auto_attach=true,
 },
 safe_output=true,
 separator=" ",
}
