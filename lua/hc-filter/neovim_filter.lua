local HCFilter=require("hc-filter.init_space")
---@class NeovimFilter
local NeovimFilter={}
local function decompose_rgb(color)
 if not color then return nil end
 local rgb=HCFilter.RGBFormat.num_to_rgb(color)
 return rgb[1],rgb[2],rgb[3]
end

local function compose_rgb(r,g,b)
 r=math.min(math.max(0,r),255)
 g=math.min(math.max(0,g),255)
 b=math.min(math.max(0,b),255)
 return HCFilter.RGBFormat.rgb_to_num({r,g,b})
end

local cache=setmetatable({},{__mode="v"})
-- 创建滤镜处理器
function NeovimFilter.create_filter(filter_func)
 local ret=cache[filter_func]
 if ret==nil then
  ret=function(color)
   if not color then return nil end
   local r,g,b=decompose_rgb(color)
   r,g,b=filter_func(r,g,b)
   return compose_rgb(r,g,b)
  end
  cache[filter_func]=ret
 end
 return ret
end
-- 处理单个颜色
function NeovimFilter.apply_to_color(color,filter_func)
 if not color or not filter_func then
  return color
 end
 local processor=NeovimFilter.create_filter(filter_func)
 return processor(color)
end
function NeovimFilter.apply_to_hl(hl,filter_func,options)
 local new_hl=vim.deepcopy(hl)
 local processor=NeovimFilter.create_filter(filter_func)
 local processed=false
 for key in pairs(options) do
  if new_hl[key] then
   new_hl[key]=processor(new_hl[key])
   processed=true
  end
 end
 if processed then
  return new_hl
 end
 return false
end
-- 处理单个高亮组
function NeovimFilter.apply_to_name(name,filter_func,options)
 local hl=vim.api.nvim_get_hl(0,{name=name})
 if hl.link~=nil then
  return false
 end
 local new_hl=NeovimFilter.apply_to_hl(hl,filter_func,options)
 if new_hl then
  vim.api.nvim_set_hl(0,name,new_hl)
  return new_hl
 end
 return false
end
local function run_block_with_scheduled_resuming(fn)
 local co=coroutine.create(fn)
 local function resume_scheduled()
  vim.schedule(function()
   coroutine.resume(co)
  end)
  coroutine.yield()
 end
 coroutine.resume(co,resume_scheduled)
end

local function serialize_simple(value)
 local t=type(value)
 if t=="string" then
  return string.format("%q",value)
 elseif t=="table" then
  local buffer={}
  for k,v in pairs(value) do
   table.insert(buffer,"["..serialize_simple(k).."]="..serialize_simple(v)..",")
  end
  table.sort(buffer)
  return "{"..table.concat(buffer).."}"
 else
  return tostring(value)
 end
end
-- 批量处理高亮组
function NeovimFilter.apply_to_all(filter_func,options)
 run_block_with_scheduled_resuming(function(resume_scheduled)
  local cache={}
  options=options or {}
  local highlights=vim.fn.getcompletion("","highlight")
  for _,name in ipairs(highlights) do
   resume_scheduled()
   local hl=vim.api.nvim_get_hl(0,{name=name})
   local key=serialize_simple(hl)
   local new_hl=cache[key]
   if new_hl==nil then
    new_hl=NeovimFilter.apply_to_hl(hl,filter_func,options)
    if new_hl==nil then
     new_hl=false
    end
    cache[key]=new_hl
   end
   if new_hl then
    vim.api.nvim_set_hl(0,name,new_hl)
   end
  end
 end)
end
-- 处理多个特定高亮组
function NeovimFilter.apply_to_names(names,filter_func,options)
 options=options or {}
 for _,name in ipairs(names) do
  NeovimFilter.apply_to_name(name,filter_func,options)
 end
end
return NeovimFilter
