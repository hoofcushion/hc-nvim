local Config=require("hc-nvim.config")
return {
 spec=require("hc-nvim.setup.mapping").wkspec,
 delay=function(ctx)
  return ctx.plugin and 0 or 10
 end,
 win={
  border=require("hc-nvim.rsc").border[Config.ui.border],
  padding={0,1},
 },
 layout={
  spacing=1,
  width={min=0,max=25},
  height={min=5,max=25},
  align="center",
 },
 triggers=(function()
  local ret={{"<auto>",mode="nixsotc"}}
  for i=("a"):byte(),("z"):byte() do
   table.insert(ret,{string.char(i),mode="nixsotc"})
  end
  return ret
 end)(),
 expand=1,
 icons={
  rules=false,
  keys={
   Esc="Esc",
   BS="⌫ ",
  },
 },
}
