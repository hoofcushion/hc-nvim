local Util=require("hc-nvim.util")
---@class EventSpec
---@field event string
---@field pattern string[]?

---@param event string|EventSpec
---@return EventSpec
local function to_event_spec(event)
 if type(event)=="string" then
  local pos=event:lower():find(" ")
  if pos then
   event={event=event:sub(1,pos-1),pattern=vim.split(event:sub(pos+1),",%s+")}
  else
   event={event=event}
  end
 end
 if event.pattern then
  event.pattern=Util.totable(event.pattern)
 end
 return event
end
---@class Event
---@field specs EventSpec[]
local Event={
 specs={},
}
---@param events string|EventSpec|(string|EventSpec)[]?
---@return Event
function Event.new(events)
 local obj=Util.Class.new(Event)
 obj.specs={}
 if events then
  obj:extend(events)
 end
 return obj
end
---@param event string|EventSpec|string[]|EventSpec[]
---@return EventSpec[]
function Event.parse(event)
 if type(event)=="string" or Util.is_list(event)==false then
  event={event}
 end
 for i,v in ipairs(event) do
  event[i]=to_event_spec(v)
 end
 return event
end
---@param spec string|EventSpec
function Event:add(spec)
 table.insert(self.specs,spec)
end
---@param events string|EventSpec|(string|EventSpec)[]
function Event:extend(events)
 for _,spec in ipairs(Event.parse(events)) do
  self:add(spec)
 end
end
local function stack_callback(callback,any,id)
 return function(ev)
  local done=callback(ev)
  if done and any then
   vim.api.nvim_del_augroup_by_id(id)
  end
  return done
 end
end
local function get_group_id(group)
 if type(group)=="number" then
  return group
 end
 if group==nil then
  group="Unnamed: "..tostring(os.clock())
 end
 return vim.api.nvim_create_augroup(group,{clear=true})
end
function Event:create_autocmd(opts,any)
 opts=opts~=nil and vim.deepcopy(opts) or {}
 if any then
  local id=get_group_id(opts.group)
  opts.group=id
  opts.callback=stack_callback(opts.callback,any,id)
 end
 for event,pattern in self:pairs() do
  opts.pattern=pattern
  vim.api.nvim_create_autocmd(event,opts)
 end
end
function Event:lazyevents()
 return vim.deepcopy(self.specs)
end
function Event:pairs()
 local i=0
 local specs=self.specs
 return function()
  i=i+1
  local spec=specs[i]
  if spec then
   return spec.event,spec.pattern
  end
 end
end
function Event:getname(group)
 local cat={}
 for event,pattern in self:pairs() do
  local name=event
  if pattern then
   name=name.." "..table.concat(pattern,", ")
  end
  table.insert(cat,name)
 end
 local ret=table.concat(cat,"; ")
 if group then
  ret=("%s: %s"):format(group,ret)
 end
 return ret
end
---@param name string
---@param opts {clear:boolean,once:boolean,trigger:fun(ev):boolean?}
---@return EventSpec
function Event:create_user_event(name,opts)
 if opts==nil then
  opts={}
 end
 if opts.trigger==nil then
  opts.trigger=function(_) return true end
 end
 local id=get_group_id(name)
 self:create_autocmd({
  group=id,
  callback=function(event)
   local ok=opts.trigger(event)
   if ok then
    vim.api.nvim_exec_autocmds("User",{pattern=name})
    if opts.clear then
     vim.api.nvim_del_augroup_by_id(id)
    end
   end
   if ok and opts.once then
    return true
   end
  end,
 })
 return {event="User",pattern=name}
end
---@param specs EventSpec[]
---@param name string
local function sequence(specs,name)
 local spec=table.remove(specs,1)
 if spec==nil then
  vim.api.nvim_exec_autocmds("User",{pattern=name})
  return
 end
 Event.new(spec):create_autocmd({
  once=true,
  callback=function()
   sequence(specs,name)
  end,
 })
end
---@return EventSpec
function Event:sequence()
 local name=self:getname("Sequence")
 sequence(vim.deepcopy(self.specs),name)
 return {event="User",pattern=name}
end
function Event:all_happen(opts)
 opts=opts or {}
 local name=self:getname("AllHappen")
 local done={}
 for event in self:pairs() do
  done[event]=true
 end
 opts.trigger=function(ev)
  done[ev.event]=nil
  if next(done)==nil then
   return true
  end
 end
 return self:create_user_event(name,opts)
end
return Event
