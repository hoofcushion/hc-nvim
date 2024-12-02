local Util=require("hc-nvim.util")
Util.TaskSequence.new()
 :extend({
  function() require("luasnip.loaders.from_vscode").lazy_load() end,
  function() require("luasnip.loaders.from_snipmate").lazy_load() end,
  function()
   require("luasnip.loaders.from_lua").lazy_load({
    paths={
     vim.fn.stdpath("config").."/snippets",
    },
   })
  end,
 })
 :start(5)
