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
   interval=3,     -- 3 cursor move for 1 step
   loopover=360/3, -- 3° each step
  },
  timer={
   enabled=true,
   loopover=360/2, -- 2° each step
  },
 },
 code_lens={enabled=false},
 auto_format={enabled=false},
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
