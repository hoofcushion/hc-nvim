local Config=require("hc-nvim.config")
return {
 default_mappings=false,
 builtin_marks={"c",".","<",">","^","(",")","{","}"},
 refresh_interval=Config.performance.refresh,
 excluded_buftypes=Config.performance.exclude.buftypes,
 excluded_filetypes=Config.performance.exclude.filetypes,
}
