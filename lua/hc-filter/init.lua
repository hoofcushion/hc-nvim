local N=require("hc-nvim")
---@class HC-Filter
local M=require("hc-filter.init_space")
N.lazy(function() return require("hc-filter.color_filter") end,   function(t) M.ColorFilter=t end)
N.lazy(function() return require("hc-filter.filter_preset") end,  function(t) M.FilterPreset=t end)
N.lazy(function() return require("hc-nvim.util.color_format") end,function(t) M.ColorFormat=t end)
N.lazy(function() return require("hc-filter.neovim_filter") end,  function(t) M.NeovimFilter=t end)
N.lazy(function() return require("hc-nvim.util.rgb_format") end,  function(t) M.RGBFormat=t end)
M.random_filter_record={}
---@class HC-Filter.option.spec
local spec={name="",value=0,scope={}}
---@enum(key) HC-Filter.option.preset
local presets={
 grayscale={
  {name="grayscale_srgb",value=true},
 },
 black_and_white={
  {name="lightup",   value=100, scope={fg=true}},
  {name="contrast",  value=100, scope={fg=true}},
  {name="lightness", value=-100,scope={bg=true}},
  {name="saturation",value=0},
 },
 random={
  {name="random",value=1/10},
 },
 random_tune={
  {name="random_tune",value=1/10},
 },
 invert={
  {name="invert",value=true},
 },

}
---@class HC-Filter.options
local default_opts={
 preset=nil, ---@type HC-Filter.option.preset
 spec_list={}, ---@type HC-Filter.option.spec[]
}
---@param opts HC-Filter.options
function M.setup(opts)
 math.randomseed(os.clock())
 opts=(opts and next(opts) and opts) or default_opts
 local function dofilter()
  local spec_list=opts.spec_list or presets[opts.preset]
  if type(spec_list)~="table" then
   return
  end
  for _,set in ipairs(spec_list) do
   if type(set)~="table" then
    set={value=set}
   end
   if set and set.name and set.value then
    local preset=M.FilterPreset[set.name]
    if preset then
     local value=set.value
     local instance=preset(value)
     M.NeovimFilter.apply_to_all(instance,set.scope or {fg=true,bg=true})
    end
   end
  end
 end
 local done=false
 if vim.v.vim_did_enter then
  if not done then
   done=true
   dofilter()
  end
 else
  vim.api.nvim_create_autocmd("VimEnter",{
   callback=function()
    if not done then
     done=true
     dofilter()
    end
   end,
  })
 end
 vim.api.nvim_create_autocmd("ColorScheme",{
  callback=function()
   done=true
   dofilter()
  end,
 })
end
return M
