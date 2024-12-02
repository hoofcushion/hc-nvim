local Config=require("hc-func.config")
local Options=Config.options.rainbowcursor
local Util=require("hc-func.util")
local Autocmd=Util.Autocmd.new()
local Updater=Util.Timer.new()
local ColorIter={
 index=1,
 length=0,
 list={},
}
function ColorIter:attach(list)
 self.list=list
 self.length=#list
end
---@param step number
function ColorIter:next(step)
 self.index=self.index+step
 if self.index>self.length then
  self.index=1
 end
end
function ColorIter:get()
 return self.list[math.floor(self.index)]
end
function ColorIter:fini()
 self.index=1
 self.length=0
 self.list={}
end
--- ---
--- Shortcuts
--- ---
---@param p number
---@param q number
---@param h number
local function aux(p,q,h)
 h=math.abs(h%1)
 if h<1/6 then return p+(q-p)*6*h end
 if h<1/2 then return q end
 if h<2/3 then return p+(q-p)*(2/3-h)*6 end
 return p
end
---@param h number
---@param s number
---@param l number
---@return ... integer
local function hsl_to_rgb(h,s,l)
 h,s,l=h/360,s/100,l/100
 local q=l<0.5 and l*(1+s) or l+s-l*s
 local p=2*l-q
 local r,g,b=aux(p,q,h+1/3),aux(p,q,h),aux(p,q,h-1/3)
 return math.floor(r*255),math.floor(g*255),math.floor(b*255)
end
local function rgb_to_colorcode(r,g,b)
 return string.format("#%02x%02x%02x",r,g,b)
end
local function set_cursor_hlgroup(hlgroup)
 local guicursor={}
 for _,item in ipairs(vim.opt.guicursor:get()) do
  local prefix=item:match("(.-:.+)%-?")
  item=prefix.."-"..hlgroup
  table.insert(guicursor,item)
 end
 vim.opt.guicursor=guicursor
end
local HiGroup={
 hl_group="",
}
function HiGroup:set(hl_opts)
 vim.api.nvim_set_hl(0,self.hl_group,hl_opts)
 self.hl_opts=hl_opts
end
function HiGroup:fini()
 self.hl_group=nil
 self.hl_opts=nil
end
local RainbowCursor={
 guicursor="",
}
local M={}
function M.activate()
 RainbowCursor.guicursor=vim.o.guicursor
 set_cursor_hlgroup(Options.hl_group)
 Autocmd:activate()
 Updater:start()
 HiGroup:set(ColorIter:get())
end
function M.deactivate()
 vim.o.guicursor=RainbowCursor.guicursor
 Autocmd:deactivate()
 Updater:stop()
end
function M.enable()
 HiGroup.hl_group=Options.hl_group
 local FuncBind=Util.FuncBind.new(Options.throttle)
 --- ---
 --- setup rainbow cursor iterator
 --- ---
 local colors
 colors=Options.colors
 if type(colors)=="number" then
  local loopover=colors
  colors={}
  for i=0,360,360/loopover do
   local color=rgb_to_colorcode(hsl_to_rgb(i,100,50))
   table.insert(colors,{bg=color})
  end
  if vim.deep_equal(colors[1],colors[#colors]) then
   table.remove(colors)
  end
 end
 ColorIter:attach(colors)
 local refresh_cb=FuncBind:bind(function()
  local hl_opts=ColorIter:get()
  if hl_opts~=HiGroup.hl_opts then
   HiGroup:set(hl_opts)
  end
 end)
 --- ---
 --- setup timer and autocmd
 --- ---
 if Options.timer.enabled then
  if Options.timer.interval then
   local timer_step=ColorIter.length/Options.autocmd.loopover
   local timer_cb=function()
    ColorIter:next(timer_step)
   end
   Updater:new_timer(0,Options.timer.interval,timer_cb)
  end
  if Options.timer.refresh then
   Updater:new_timer(0,Options.timer.refresh,refresh_cb)
  end
  Updater:start()
 end
 --- ---
 --- setup autocmd
 --- ---
 if Options.autocmd.enabled then
  if Options.autocmd.event then
   local autocmd_step=ColorIter.length/Options.autocmd.loopover
   local interval=Options.autocmd.interval
   local i=0
   local function autocmd_cb()
    i=i+1
    if i==interval then
     i=0
     ColorIter:next(autocmd_step)
    end
   end
   Autocmd:add({{Options.autocmd.event,{callback=autocmd_cb}}})
  end
  if Options.autocmd.refresh then
   Autocmd:add({{Options.autocmd.refresh,{callback=refresh_cb}}})
  end
  Autocmd:create()
 end
end
function M.disable()
 Updater:fini()
 Autocmd:fini()
 HiGroup:fini()
end
return M
