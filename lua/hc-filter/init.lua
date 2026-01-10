local N=require("hc-nvim")
---@class HC-Filter
local M=require("hc-filter.init_space")
N.lazy(function() return require("hc-filter.color_filter") end,   function(t) M.ColorFilter=t end)
N.lazy(function() return require("hc-nvim.util.color_format") end,function(t) M.ColorFormat=t end)
N.lazy(function() return require("hc-filter.neovim_filter") end,  function(t) M.NeovimFilter=t end)
N.lazy(function() return require("hc-nvim.util.rgb_format") end,  function(t) M.RGBFormat=t end)
M.random_filter_record={}
function M.random_filter(factor)
 M.NeovimFilter.apply_to_all(function(r,g,b)
  local rgb={r,g,b}
  local rng={unpack(rgb)}
  local filter={
   -- random filter formula: 1 ± (factor) * (random number) * (srgb lightness scale [0.2126,0.7152,0.0722])
   1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.2126),
   1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.7152),
   1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.0722),
  }
  --- save the filter tune
  M.random_filter_record=filter
  rng[1]=rng[1]*filter[1]
  rng[2]=rng[2]*filter[2]
  rng[3]=rng[3]*filter[3]
  return unpack(M.RGBFormat.rgb_to_normalize(rng))
 end,{fg=true,bg=true})
end
function M.setup(opts)
 opts=opts or {}
 local factor=opts.random_factor or (1/10)
 local done=false
 if vim.v.vim_did_enter then
  if not done then
   done=true
   M.random_filter(factor)
  end
 else
  vim.api.nvim_create_autocmd("VimEnter",{
   callback=function()
    if not done then
     done=true
     M.random_filter(factor)
    end
   end,
  })
 end
 vim.api.nvim_create_autocmd("ColorScheme",{
  callback=function()
   done=true
   M.random_filter(factor)
  end,
 })
end
return M
