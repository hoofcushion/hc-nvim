local Util=require("hc-nvim.util")
return Util.pipe({})(function(x)
 if require("hc-nvim.config").locale.current.language=="zh" then
  local header=require("hc-nvim.rsc.header")
  Util.tbl_deep_extend(x,{
   config={
    header=vim.split(header,"\n"),
    footer={},
   },
  })
 end
 return x
end)()
