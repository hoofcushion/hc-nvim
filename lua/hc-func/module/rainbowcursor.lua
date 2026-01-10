local Config=require("hc-func.config")
local Options=Config.options.rainbowcursor
local Util=require("hc-nvim.util")
local Autocmd=Util.ConductedAutocmd.new()
local Updater=Util.ConductedTimer.new()
local Iterator={
 index=1,
 length=0,
 list={},
}
function Iterator:attach(list)
 self.list=list
 self.length=#list
end
---@param step number
function Iterator:next(step)
 self.index=self.index+step
 if self.index>self.length then
  self.index=1
 end
end
function Iterator:get()
 return self.list[math.floor(self.index)]
end
function Iterator:fini()
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
local function generate_colors_palette(count)
 local colors={}
 local step=360/count
 for i=0,count do
  local hue=i*step
  local r,g,b=hsl_to_rgb(hue,100,50)
  table.insert(colors,{bg=rgb_to_colorcode(r,g,b)})
 end
 if colors[1].bg==colors[#colors].bg then
  table.remove(colors)
 end
 return colors
end
local HiGroup={
 hl_group="",
}
function HiGroup:set(hl_opts)
 if hl_opts~=self.hl_opts then
  self.hl_opts=hl_opts
  vim.api.nvim_set_hl(0,self.hl_group,hl_opts)
 end
end
function HiGroup:fini()
 self.hl_group=nil
 self.hl_opts=nil
end
local M={}
function M.activate()
 Autocmd:activate()
 Updater:enable()
 vim.schedule(function()
  set_cursor_hlgroup(Options.hl_group)
  HiGroup:set(Iterator:get())
 end)
end
function M.deactivate()
 Autocmd:deactivate()
 Updater:disable()
end
function M.enable()
 HiGroup.hl_group=Options.hl_group
 --- ---
 --- setup rainbow cursor iterator
 --- ---
 if type(Options.colors)=="number" then
  Iterator:attach(generate_colors_palette(Options.colors))
 else
  Iterator:attach(Options.colors)
 end
 local refresh_cb=Util.throttle(Options.throttle,vim.schedule_wrap(function()
  HiGroup:set(Iterator:get())
 end))
 --- ---
 --- setup timer and autocmd
 --- ---
 if Options.timer.enabled then
  if Options.timer.interval then
   local timer_step=Iterator.length/Options.autocmd.loopover
   local function timer_cb()
    Iterator:next(timer_step)
   end
   Updater:add(0,Options.timer.interval,timer_cb)
  end
  -- independent refresher for timer
  if Options.timer.refresh then
   Updater:add(0,Options.timer.refresh,refresh_cb)
  end
  Updater:enable()
 end
 --- ---
 --- setup autocmd
 --- ---
 if Options.autocmd.enabled then
  if Options.autocmd.event then
   local autocmd_step=Iterator.length/Options.autocmd.loopover
   local interval=Options.autocmd.interval
   local i=0
   local refresh=Options.autocmd.refresh
   local function autocmd_cb()
    i=i+1
    if i==interval then
     i=0
     Iterator:next(autocmd_step)
     if refresh then
      refresh_cb()
     end
    end
   end
   Autocmd:add({{Options.autocmd.event,{callback=autocmd_cb}}})
  end
  Autocmd:enable()
 end
end
function M.disable()
 Updater:fini()
 Autocmd:fini()
 HiGroup:fini()
 Iterator:fini()
end
return M
