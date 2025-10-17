---
--- complex event control
--- all means *all* event happens
--- any means *any* of the event happens
--- wait means when all conditions are met, *wait* for a while, then trigger the event

if false then
 ---@class event_t
 local _event_t={
  event="FileType", ---@type vim.api.keyset.events|vim.api.keyset.events
  pattern="lua", ---@type string|string[]
  cond=function() return true end, ---@type (fun(ev:vim.api.keyset.create_autocmd.callback_args):boolean?)
 }
 ---@class step_opt
 local _step_opt={
  wait=0, ---@type integer?
  delay=5, ---@type integer?
  group="", ---@type string|integer?
  name="", ---@type string
  callback=function() end, ---@type (fun(ev:vim.api.keyset.create_autocmd.callback_args):boolean?)?
  once=nil, ---@type boolean?
  calm=false, ---@type boolean?
 }
 ---@class step_t:step_opt
 local _step_t={
  all={}, ---@type event_t[]?
  any={}, ---@type event_t[]?
 }
 ---@class steps_t:step_opt
 local _steps_t={
  steps={}, ---@type step_t[]
 }
end
local Event={}
---@param event string|event_t
---@return event_t
function Event.event_normalize(event)
 if type(event)=="string" then
  local _=vim.split(event," ")
  local event_t={
   event=_[1],
   pattern=_[2] and _[2]~="" and vim.split(_[2],",") or nil,
  }
  return event_t
 end
 return event
end
---@param events string|string[]|event_t|event_t[]
---@return event_t[]?
function Event.events_normalize(events)
 -- string
 if type(events)=="string" then
  local event_t=Event.event_normalize(events)
  return {event_t}
 end
 if type(events)=="table" then
  -- list
  if events[1]~=nil then
   local event_list={}
   for _,event in ipairs(events) do
    table.insert(event_list,Event.event_normalize(event))
   end
   return event_list
  elseif next(events)~=nil then
   -- event_t
   return {events}
  end
 end
end
---@param step_t step_t
function Event._step_normalize(step_t)
 step_t=step_t or {}
 step_t.name=step_t.name or tostring({})
 local group=step_t.group
 if type(group)=="string" then
  step_t.group=vim.api.nvim_create_augroup(group,{clear=true})
 end
 if step_t.all then
  step_t.all=Event.events_normalize(step_t.all)
 end
 if step_t.any then
  step_t.any=Event.events_normalize(step_t.any)
 end
 return step_t
end
---@param steps_t steps_t
function Event.steps_t_normalize(steps_t)
 steps_t=steps_t or {}
 steps_t.steps=steps_t.steps or {}
 steps_t.name=steps_t.name or tostring({})
 local group=steps_t.group
 if type(group)=="string" then
  steps_t.group=vim.api.nvim_create_augroup(group,{clear=true})
 end
 for i,v in ipairs(steps_t) do
  steps_t[i]=Event._step_normalize(v)
 end
 return steps_t
end
---@param step_t step_t
---@return event_t
function Event.create(step_t)
 step_t=Event._step_normalize(step_t)
 --- delay
 if step_t.delay then
  vim.defer_fn(function()
                local _step_t=vim.deepcopy(step_t)
                _step_t.delay=nil
                Event.create(_step_t)
               end,step_t.delay)
  return {event="User",pattern=step_t.name}
 end
 --- exec autocmd
 local function exec(v)
  if v.calm then
   vim.schedule(function()
    vim.api.nvim_exec_autocmds("User",{pattern=step_t.name})
   end)
  else
   vim.api.nvim_exec_autocmds("User",{pattern=step_t.name})
  end
 end
 --- any
 local rests=0
 if step_t.any then
  rests=rests+1
  local ids={}
  local function clear()
   for _,id in ipairs(ids) do
    vim.api.nvim_del_autocmd(id)
   end
  end
  for _,v in ipairs(step_t.any) do
   local id=vim.api.nvim_create_autocmd(v.event,{
    group=step_t.group,
    pattern=v.pattern,
    callback=function(ev)
     if type(v.cond)~="function" or v.cond(ev) then
      rests=rests-1
      if rests<=0 then
       exec(v)
      end
      clear()
      return true
     end
    end,
   })
   table.insert(ids,id)
  end
 end
 --- all
 if step_t.all then
  rests=rests+#step_t.all
  for _,v in ipairs(step_t.all) do
   vim.api.nvim_create_autocmd(v.event,{
    group=step_t.group,
    pattern=v.pattern,
    callback=function(ev)
     if type(v.cond)~="function" or v.cond(ev) then
      rests=rests-1
      if rests<=0 then
       exec(v)
      end
      return true
     end
    end,
   })
  end
 end
 --- callback
 vim.api.nvim_create_autocmd("User",{
  group=step_t.group,
  pattern=step_t.name,
  callback=function(ev)
   if step_t.callback then
    if step_t.wait then
     vim.defer_fn(function()
                   step_t.callback(ev)
                  end,step_t.wait)
    else
     step_t.callback(ev)
    end
   end
   if not step_t.once then
    Event.create(step_t)
   end
   return true
  end,
 })
 return {event="User",pattern=step_t.name}
end
---@param steps_t steps_t
---@return event_t
function Event.sequence(steps_t)
 steps_t=Event.steps_t_normalize(steps_t)
 -- Handle delay if specified
 if steps_t.delay then
  vim.defer_fn(function()
                local _steps=vim.deepcopy(steps_t)
                _steps.delay=nil
                Event.sequence(_steps)
               end,steps_t.delay)
  return {event="User",pattern=steps_t.name}
 end
 local i,e=1,#steps_t.steps
 -- Function to process the next step
 local function process_next_step()
  local step=vim.deepcopy(steps_t.steps[i])
  local callback=step.callback
  step.group=steps_t.group
  step.once=true
  step.callback=function(ev)
   if type(callback)=="function" then
    callback(ev)
   end
   i=i+1
   if i>e then
    if steps_t.callback then
     if steps_t.wait then
      vim.defer_fn(function()
                    steps_t.callback(ev)
                   end,steps_t.wait)
     else
      steps_t.callback(ev)
     end
    end
    if not steps_t.once then
     Event.sequence(steps_t)
    end
   else
    process_next_step()
   end
   return true
  end
  -- Create the current step
  Event.create(step)
 end
 -- Start processing the first step
 process_next_step()
 return {event="User",pattern=steps_t.name}
end
function Event.from(name,init)
 init(function()
  vim.api.nvim_exec_autocmds("User",{pattern=name})
 end)
 return {event="User",pattern=name}
end
return Event
