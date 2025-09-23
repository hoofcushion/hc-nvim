vim.cmd([[
let g:matchup_matchparen_deferred = 100
let g:matchup_matchparen_stopline = 100
let g:matchup_treesitter_stopline = 100
let g:matchup_delim_noskips = 1
let g:matchup_matchparen_insert_timeout= 30
]])
return {
 matchup={
  enable=true,
 },
}
