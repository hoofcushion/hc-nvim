local Config=require("hc-nvim.config")
return {
 icons={
  kinds={
   symbols=require("hc-nvim.config.rsc").kind[Config.ui.kind]:sub(1,1):suffix(" "),
  },
  ui={
   bar={
    separator=" ",
    extends="…",
   },
  },
 },
 bar={
  update_debounce=Config.performance.debounce,
 },
}
