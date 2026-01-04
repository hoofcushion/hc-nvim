return {
 {
  {"nvim-cmp"},
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
 {
  {"blink.cmp"},
  function()
   local blink_cmp_config=require("blink.cmp.config")
   blink_cmp_config.merge_with({
    snippets={
     expand=function(snippet) require("luasnip").lsp_expand(snippet) end,
     active=function(filter)
      if filter and filter.direction then
       return require("luasnip").jumpable(filter.direction)
      end
      return require("luasnip").in_snippet()
     end,
     jump=function(direction) require("luasnip").jump(direction) end,
    },
   })
  end,
 },
}
