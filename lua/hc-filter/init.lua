local HCNvim=require("hc-nvim.init_space")
---@class HC-Filter
local HCFilter=require("hc-filter.init_space")
HCNvim.lazy(function() return require("hc-filter.color_filter") end,   function(t) HCFilter.ColorFilter=t end)
HCNvim.lazy(function() return require("hc-filter.filter_preset") end,  function(t) HCFilter.FilterPreset=t end)
HCNvim.lazy(function() return require("hc-nvim.util.color_format") end,function(t) HCFilter.ColorFormat=t end)
HCNvim.lazy(function() return require("hc-filter.neovim_filter") end,  function(t) HCFilter.NeovimFilter=t end)
HCNvim.lazy(function() return require("hc-nvim.util.rgb_format") end,  function(t) HCFilter.RGBFormat=t end)
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
---@param filter_list HC-Filter.option.spec[]
local function dofilter(filter_list)
 if type(filter_list)~="table" then
  return
 end
 for _,set in ipairs(filter_list) do
  if type(set)~="table" then
   goto continue
  end
  if set and set.name and set.value then
   local preset=HCFilter.FilterPreset[set.name]
   if preset then
    local value=set.value
    local instance=preset(value)
    HCFilter.NeovimFilter.apply_to_all(instance,set.scope or {fg=true,bg=true})
   end
  end
  ::continue::
 end
end
---@param filter_list HC-Filter.option.spec[]
local function setup_filter(filter_list)
 local done=false
 if vim.v.vim_did_enter then
  if not done then
   done=true
   dofilter(filter_list)
  end
 else
  vim.api.nvim_create_autocmd("VimEnter",{
   group=vim.api.nvim_create_augroup("HC-Filter VimEnter Setup",{clear=true}),
   callback=function()
    if not done then
     done=true
     dofilter(filter_list)
    end
   end,
  })
 end
 vim.api.nvim_create_autocmd("ColorScheme",{
  group=vim.api.nvim_create_augroup("HC-Filter ColorScheme Setup",{clear=true}),
  callback=function()
   done=true
   dofilter(filter_list)
  end,
 })
end
---@param opts HC-Filter.options
function HCFilter.setup(opts)
 math.randomseed(os.clock())
 opts=(opts and next(opts) and opts) or default_opts
 local filter_list=opts.spec_list or presets[opts.preset]
 setup_filter(filter_list)
end
return HCFilter
