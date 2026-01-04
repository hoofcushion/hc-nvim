return {
 {
  {"lualine.nvim"},
  function()
   local fapi=require("fittencode.api").api
   local sections={
    {function() return "AI" end,cond=fapi.has_suggestions,color={fg="#37b0e7",bg="#101945"}},
    -- {function() return fengine.get_suggestions().lines[1] end,cond=fengine.has_suggestions,color={fg="#37b0e7",bg="#101945"}},
   }
   local lualine=require("lualine")
   local opts=lualine.get_config()
   vim.list_extend(opts.sections.lualine_x,sections)
   lualine.setup(opts)
  end,
 },
}
