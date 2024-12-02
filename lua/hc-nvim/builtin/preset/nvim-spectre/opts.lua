return {
 color_devicons=true,
 open_cmd      ="vnew",
 live_update   =true, -- auto execute search again when you write to any file in vim
 line_sep_start="┌-----------------------------------------",
 result_padding="¦  ",
 line_sep      ="└-----------------------------------------",
 highlight     ={
  ui="String",
  search="DiffChange",
  replace="DiffDelete",
 },
}
