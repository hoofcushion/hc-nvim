local M=require("hc-filter.init_space")
---@class NeovimFilter
local NeovimFilter={}
-- 内部工具函数
local function decompose_rgb(color)
 if not color then return nil end
 local rgb=M.RGBFormat.num_to_rgb(color)
 return rgb[1],rgb[2],rgb[3]
end

local function compose_rgb(r,g,b)
 r=math.min(255,math.max(0,r))
 g=math.min(255,math.max(0,g))
 b=math.min(255,math.max(0,b))
 return M.RGBFormat.rgb_to_num({r,g,b})
end

-- 创建滤镜处理器
function NeovimFilter.create_filter(filter_func)
 return function(color)
  if not color then return nil end
  local r,g,b=decompose_rgb(color)
  r,g,b=filter_func(r,g,b)
  return compose_rgb(r,g,b)
 end
end
-- 处理单个颜色
function NeovimFilter.apply_to_color(color,filter_func)
 if not color or not filter_func then
  return color
 end
 local processor=NeovimFilter.create_filter(filter_func)
 return processor(color)
end
-- 处理单个高亮组
function NeovimFilter.apply_to_highlight(name,filter_func,options)
 local hl=vim.api.nvim_get_hl(0,{name=name})
 if hl.link~=nil then
  return false
 end
 local processor=NeovimFilter.create_filter(filter_func)
 local processed=false
 for key in pairs(options) do
  if hl[key] then
   hl[key]=processor(hl[key])
   processed=true
  end
 end
 if processed then
  vim.api.nvim_set_hl(0,name,hl)
 end
end
-- 批量处理高亮组
function NeovimFilter.apply_to_all(filter_func,options)
 options=options or {}
 local highlights=vim.fn.getcompletion("","highlight")
 for _,name in ipairs(highlights) do
  NeovimFilter.apply_to_highlight(name,filter_func,options)
 end
end
-- 处理多个特定高亮组
function NeovimFilter.apply_to_names(names,filter_func,options)
 options=options or {}
 for _,name in ipairs(names) do
  NeovimFilter.apply_to_highlight(name,filter_func,options)
 end
end
return NeovimFilter
