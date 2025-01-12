return (function(opts)
 for k,v in pairs(opts) do
  if k~="toggler" and v.enabled~=false then
   v.enabled=vim.g.vscode==nil
  end
 end
 return opts
end)({
 rainbowcursor={
  enabled=true,
  throttle=5,
  autocmd={
   loopover=360,
  },
  timer={
   enabled=false,
   loopover=360,
  },
 },
 code_lens={enabled=false},
 auto_format={enabled=false},
 inlay_hint={enabled=false},
 semantic_tokens={enabled=false},
 document_highlight={enabled=true},
 toggler={
  enabled=true,
  rule={
   rainbowcursor={
    auto_suspend=true,
   },
   default={
    size_kb={0,512},
    filetype={
     ["neo-tree"]=false,
     ["lazy"]=false,
     ["mason"]=false,
    },
   },
  },
 },
})
