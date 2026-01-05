---
--- Complex Event Control Module
---
--- `all` means *all* events must happen
--- `any` means *any* of the events happens
--- `wait` means when all conditions are met, *wait* for a while, then trigger
---

if false then
 ---@class EventDefinition
 local _EventDefinition={
  event="FileType", ---@type vim.api.keyset.events|vim.api.keyset.events[]
  pattern="lua", ---@type string|string[]|nil
  cond=function() return true end, ---@type fun(ev: table): boolean?|nil
 }
 ---@class StepOptions
 local _StepOptions={
  wait=0, ---@type integer?
  delay=5, ---@type integer?
  group="", ---@type string|integer?
  name="", ---@type string
  callback=function() end, ---@type fun(ev: table): boolean?|nil
  once=nil, ---@type boolean?
  calm=false, ---@type boolean?
 }
 ---@class StepConfig : StepOptions
 local _StepConfig={
  all={}, ---@type EventDefinition[]|string|string[]
  any={}, ---@type EventDefinition[]|string|string[]
 }
 ---@class SequenceConfig : StepOptions
 local _SequenceConfig={
  steps={}, ---@type StepConfig[]
 }
end
--- ---
-- Module Definition
--- ---
local Event={}
--- ---
-- Event Definition Normalization
--- ---

---Normalize a single event definition
---@param event string|table
---@return table
function Event.normalize_single_event(event)
 if type(event)=="string" then
  local parts=vim.split(event," ")
  local normalized={
   event=parts[1],
   pattern=parts[2] and parts[2]~="" and vim.split(parts[2],",") or nil,
  }
  return normalized
 end
 return event
end
---Normalize multiple event definitions
---@param events string|string[]|table|table[]
---@return table[]|nil
function Event.normalize_event_list(events)
 if type(events)=="string" then
  local event_def=Event.normalize_single_event(events)
  return {event_def}
 end
 if type(events)=="table" then
  -- Array-style table
  if events[1]~=nil then
   local event_list={}
   for _,event in ipairs(events) do
    table.insert(event_list,Event.normalize_single_event(event))
   end
   return event_list
   -- Single event definition
  elseif next(events)~=nil then
   return {events}
  end
 end
end
--- ---
-- Step Configuration Normalization
--- ---

---Normalize a single step configuration
---@param step_config table
---@return table
function Event.normalize_step_config(step_config)
 step_config=step_config or {}
 -- Generate unique name if not provided
 if not step_config.name or step_config.name=="" then
  step_config.name="event_step_"..tostring({})
 end
 -- Create augroup if group name is provided
 if type(step_config.group)=="string" and step_config.group~="" then
  step_config.group=vim.api.nvim_create_augroup(step_config.group,{clear=true})
 end
 -- Normalize event lists
 if step_config.all then
  step_config.all=Event.normalize_event_list(step_config.all)
 end
 if step_config.any then
  step_config.any=Event.normalize_event_list(step_config.any)
 end
 return step_config
end
---Normalize a sequence configuration
---@param sequence_config table
---@return table
function Event.normalize_sequence_config(sequence_config)
 sequence_config=sequence_config or {}
 sequence_config.steps=sequence_config.steps or {}
 -- Generate unique name if not provided
 if not sequence_config.name or sequence_config.name=="" then
  sequence_config.name="event_sequence_"..tostring({})
 end
 -- Create augroup if group name is provided
 if type(sequence_config.group)=="string" and sequence_config.group~="" then
  sequence_config.group=vim.api.nvim_create_augroup(sequence_config.group,{clear=true})
 end
 -- Normalize all steps
 for i,step in ipairs(sequence_config.steps) do
  sequence_config.steps[i]=Event.normalize_step_config(step)
 end
 return sequence_config
end
--- ---
-- Event Execution Management
--- ---

---Execute autocmds with optional scheduling
---@param step_config table
local function _execute_autocmds(step_config)
 if step_config.calm then
  vim.schedule(function()
   vim.api.nvim_exec_autocmds("User",{pattern=step_config.name})
  end)
 else
  vim.api.nvim_exec_autocmds("User",{pattern=step_config.name})
 end
end

---Handle "any" condition events
---@param step_config table
local function _setup_any_conditions(step_config)
 local remaining_count=1 -- Start with 1 to trigger when any condition is met
 local autocmd_ids={}
 ---Clear all registered autocmds
 local function clear_autocmds()
  for _,id in ipairs(autocmd_ids) do
   vim.api.nvim_del_autocmd(id)
  end
 end

 for _,event_def in ipairs(step_config.any) do
  local id=vim.api.nvim_create_autocmd(event_def.event,{
   group=step_config.group,
   pattern=event_def.pattern,
   callback=function(ev)
    if type(event_def.cond)~="function" or event_def.cond(ev) then
     remaining_count=remaining_count-1
     if remaining_count<=0 then
      _execute_autocmds(step_config)
      clear_autocmds()
     end
     return true
    end
   end,
  })
  table.insert(autocmd_ids,id)
 end
end

---Handle "all" condition events
---@param step_config table
local function _setup_all_conditions(step_config)
 local remaining_count=#step_config.all
 for _,event_def in ipairs(step_config.all) do
  vim.api.nvim_create_autocmd(event_def.event,{
   group=step_config.group,
   pattern=event_def.pattern,
   callback=function(ev)
    if type(event_def.cond)~="function" or event_def.cond(ev) then
     remaining_count=remaining_count-1
     if remaining_count<=0 then
      _execute_autocmds(step_config)
     end
     return true
    end
   end,
  })
 end
end

---Register the callback autocmd for a step
---@param step_config table
local function _register_callback_handler(step_config)
 vim.api.nvim_create_autocmd("User",{
  group=step_config.group,
  pattern=step_config.name,
  callback=function(ev)
   if step_config.callback then
    if step_config.wait then
     vim.defer_fn(function()
      step_config.callback(ev)
     end,step_config.wait)
    else
     step_config.callback(ev)
    end
   end
   -- Recreate if not "once"
   if not step_config.once then
    Event.create(step_config)
   end
   return true
  end,
 })
end

--- ---
-- Public API
--- ---

---Create a complex event trigger
---@param step_config table
---@return table
function Event.create(step_config)
 -- Normalize configuration
 step_config=Event.normalize_step_config(step_config)
 -- Handle delay
 if step_config.delay then
  vim.defer_fn(function()
   local delayed_config=vim.deepcopy(step_config)
   delayed_config.delay=nil
   Event.create(delayed_config)
  end,step_config.delay)
  return {event="User",pattern=step_config.name}
 end
 -- Setup condition handlers
 if step_config.any then
  _setup_any_conditions(step_config)
 end
 if step_config.all then
  _setup_all_conditions(step_config)
 end
 -- Register callback handler
 _register_callback_handler(step_config)
 return {event="User",pattern=step_config.name}
end
---Create a sequence of event steps
---@param sequence_config table
---@return table
function Event.sequence(sequence_config)
 -- Normalize configuration
 sequence_config=Event.normalize_sequence_config(sequence_config)
 -- Handle delay
 if sequence_config.delay then
  vim.defer_fn(function()
   local delayed_config=vim.deepcopy(sequence_config)
   delayed_config.delay=nil
   Event.sequence(delayed_config)
  end,sequence_config.delay)
  return {event="User",pattern=sequence_config.name}
 end
 local current_step=1
 local total_steps=#sequence_config.steps
 ---Process the next step in the sequence
 local function process_next_step()
  if current_step>total_steps then
   -- Execute sequence callback when all steps are done
   if sequence_config.callback then
    if sequence_config.wait then
     vim.defer_fn(function()
      sequence_config.callback()
     end,sequence_config.wait)
    else
     sequence_config.callback()
    end
   end
   -- Restart sequence if not "once"
   if not sequence_config.once then
    current_step=1
    process_next_step()
   end
   return
  end
  local step=vim.deepcopy(sequence_config.steps[current_step])
  local original_callback=step.callback
  step.group=sequence_config.group
  step.once=true
  -- Wrap the callback to advance to next step
  step.callback=function(ev)
   if type(original_callback)=="function" then
    original_callback(ev)
   end
   current_step=current_step+1
   process_next_step()
   return true
  end
  -- Create the current step
  Event.create(step)
 end

 -- Start processing
 process_next_step()
 return {event="User",pattern=sequence_config.name}
end
---Create an event from an initialization function
---@param name string
---@param init_function function
---@return table
function Event.from(name,init_function)
 init_function(function()
  vim.api.nvim_exec_autocmds("User",{pattern=name})
 end)
 return {event="User",pattern=name}
end
--- ---
-- Module Export
--- ---
return Event
