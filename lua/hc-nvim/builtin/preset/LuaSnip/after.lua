local Util=require("hc-nvim.util")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({paths={vim.fn.stdpath("config").."/snippets"}})
