local Config=require("hc-nvim.config")
return {
 input={
  border=Config.ui.border,
 },
 select={
  nui={
   border={
    style=Config.ui.border,
   },
  },
  builtin={
   border=Config.ui.border,
  },
 },
}
