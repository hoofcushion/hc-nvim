local Rsc={}
if false then
 Rsc={
  kind={
   hanzi=require("hc-nvim.rsc.kind.hanzi"),
   icon=require("hc-nvim.rsc.kind.icon"),
   letter=require("hc-nvim.rsc.kind.letter"),
   none=require("hc-nvim.rsc.kind.none"),
  },
  sign={
   hanzi=require("hc-nvim.rsc.sign.hanzi"),
   icon=require("hc-nvim.rsc.sign.icon"),
   letter=require("hc-nvim.rsc.sign.letter"),
   none=require("hc-nvim.rsc.sign.none"),
  },
  border={
   double=require("hc-nvim.rsc.border.double"),
   none=require("hc-nvim.rsc.border.none"),
   rounded=require("hc-nvim.rsc.border.rounded"),
   shadow=require("hc-nvim.rsc.border.shadow"),
   single=require("hc-nvim.rsc.border.single"),
   solid=require("hc-nvim.rsc.border.solid"),
   thick=require("hc-nvim.rsc.border.thick"),
  },
  devicon=require("hc-nvim.rsc.devicon"),
 }
end
local tree={
 kind={
  hanzi=true,
  icon=true,
  letter=true,
  none=true,
 },
 sign={
  hanzi=true,
  icon=true,
  letter=true,
  none=true,
 },
 border={
  double=true,
  none=true,
  rounded=true,
  shadow=true,
  single=true,
  solid=true,
  thick=true,
 },
 devicon=true,
}
local Util=require("hc-nvim.util")
return setmetatable(Rsc,{
 __index=Util.ModTree.create(tree,{"hc-nvim.rsc"}),
})
