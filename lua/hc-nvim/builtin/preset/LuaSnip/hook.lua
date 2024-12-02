return {
 {
  {"LuaSnip","nvim-cmp"},
  function()
   local cmp=require("cmp")
   local luasnip=require("luasnip")
   cmp.setup({
    snippet={
     expand=function(args)
      luasnip.lsp_expand(args.body)
     end,
    },
   })
  end,
 },
}
