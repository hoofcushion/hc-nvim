---
--- Complex event control
--- all means *all* event happens
--- any means *any* of the event happens
--- wait means when all conditions are met, *wait* for a while, then trigger the event

---@class event_t
local event_t={
 event="FileType",
 pattern="*.lua", ---@type string|string[]
 cond=function(ev)
  return ev.file:match("Game")
 end,
}
---@param event string|event_t
---@return event_t
local function event_normalize(event)
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
---@return event_t[]
local function events_normalize(events)
 -- string
 if type(events)=="string" then
  local event_t=event_normalize(events)
  return {event_t}
 end
 if type(events)=="table" then
  -- list
  if events[1]~=nil then
   local event_list={}
   for i,event in ipairs(events) do
    table.insert(event_list,event_normalize(event))
   end
   return event_list
  else
   -- event_t
   return {events}
  end
 end
 error("Wrong type of events "..type(events))
end
---@class step_t
local step_t={
 all={}, ---@type event_t[]
 any={}, ---@type event_t[]
 wait=0, ---@type integer
 delay=5, ---@type integer
}
---@param step
local function step_normalize(step)
 if step.all then
  step.all=events_normalize(step.all)
 end
 if step.any then
  step.any=events_normalize(step.any)
 end
 return step
end
local EventX={}
function EventX.create(step,opts)
 step=step_normalize(step)
 opts=opts or {}
 opts.name=opts.name or tostring({})
 -- delay
 if step.delay then
  vim.defer_fn(function()
                local step=vim.deepcopy(step)
                step.delay=nil
                EventX.create(step,opts)
               end,step.delay)
  return
 end
 local rests=0
 -- any
 if step.any then
  rests=rests+1
  local ids={}
  for _,v in ipairs(step.any) do
   local id=vim.api.nvim_create_autocmd(v.event,{
    pattern=v.pattern,
    callback=function(ev)
     if type(v.cond)~="function" or v.cond(ev) then
      rests=rests-1
      if rests<=0 then
       vim.api.nvim_exec_autocmds("User",{pattern=opts.name})
      end
      -- clear all ids
      for _,id in ipairs(ids) do
       vim.api.nvim_del_autocmd(id)
      end
      return true
     end
    end,
   })
   table.insert(ids,id)
  end
 end
 -- all
 if step.all then
  rests=rests+#step.all
  for _,v in ipairs(step.all) do
   vim.api.nvim_create_autocmd(v.event,{
    pattern=v.pattern,
    callback=function(ev)
     if type(v.cond)~="function" or v.cond(ev) then
      rests=rests-1
      if rests<=0 then
       vim.api.nvim_exec_autocmds("User",{pattern=opts.name})
      end
      return true
     end
    end,
   })
  end
 end
 if step.wait then
  vim.api.nvim_create_autocmd("User",{
   pattern=opts.name,
   callback=function(ev)
    vim.defer_fn(function()
                  opts.callback(ev)
                 end,step.wait)
    return true
   end,
  })
 else
  vim.api.nvim_create_autocmd("User",{
   pattern=opts.name,
   callback=function(ev)
    opts.callback(ev)
    return true
   end,
  })
 end
end
local event=EventX.create(
 {all={"BufEnter *.lua","BufEnter *.md"},any={"CursorMoved","CursorMovedI"}},
 {name="Composite",callback=function() vim.print("Hello world.") end}
)
