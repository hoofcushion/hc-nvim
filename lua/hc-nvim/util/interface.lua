local api=vim.api
local Util=require("hc-nvim.util.init_space")
-- 辅助函数
local function _set(buffer,mode,lhs,rhs,opts)
 --- HACK: Work-around for nvim_buf_del_keymap
 rhs=rhs.."<ignore>"
 if buffer~=nil then
  api.nvim_buf_set_keymap(buffer,mode,lhs,rhs,opts)
  return
 end
 api.nvim_set_keymap(mode,lhs,rhs,opts)
end

local function _del(buffer,mode,lhs)
 if buffer~=nil then
  api.nvim_buf_del_keymap(buffer,mode,lhs)
  return
 end
 api.nvim_del_keymap(mode,lhs)
end

---@param buffer integer?
---@param mode string[]
---@param lhs string[]
---@param rhs string|function
---@param opts vim.keymap.set.Opts
---@param fallback boolean?
local function keymap_set(buffer,mode,lhs,rhs,opts,fallback)
 opts=vim.deepcopy(opts)
 if opts.expr==true and opts.replace_keycodes==nil then
  opts.replace_keycodes=true
 end
 if opts.remap~=nil then
  opts.remap=nil
  opts.noremap=not opts.remap
 end
 for _,_lhs in ipairs(lhs) do
  for _,_mode in ipairs(mode) do
   local _rhs=rhs
   if type(_rhs)=="function" then
    opts.callback=_rhs
    _rhs=""
   end
   local cb=opts.callback
   if cb then
    if opts.expr then
     cb=(function(old)
      return function()
       return old(_lhs)
      end
     end)(cb)
    end
    if fallback then
     cb=(function(old)
      local keys=api.nvim_replace_termcodes(_lhs,true,false,true)
      return function()
       local ret=old()
       if not ret then
        api.nvim_feedkeys(keys,"n",false)
       end
      end
     end)(cb)
    end
    opts.callback=cb
   end
   pcall(function()
    _set(buffer,_mode,_lhs,_rhs,opts)
   end)
  end
 end
end

---@param buffer integer?
---@param mode string|string[]
---@param lhs string|string[]
local function keymap_del(buffer,mode,lhs)
 for _,l in Util.pipairs(lhs) do
  for _,m in Util.pipairs(mode) do
   pcall(function()
    _del(buffer,m,l)
   end)
  end
 end
end

local function resolve_buffer(buffer)
 return buffer==true and 0 or tonumber(buffer)
end

---@class RawSpec
---@field override? RawSpec
---@field wkspec? table
---@field cond? function|boolean
---@field fallback? boolean
---@field lazykey? boolean
---@field name? any
---@field priority? integer
---@field tags? any|any[]
---@field desc? string
---@field cmd? string
---@field lhs? string[]
---@field mode? string|string[]
---@field opts? vim.keymap.set.Opts
---@field rhs? string|function
---@field suffix? string
---@field event? string|string[]
---@field pattern? string|string[]
---@field buffer? boolean
---@field once? boolean
---@field prefix? string
---@field index? string
---@field value? any
---@field key_as_lhs? boolean

---@class Spec
---@field cond        function|boolean
---@field fallback    boolean
---@field lazykey     boolean
---@field name?       any
---@field priority    integer
---@field tags        table<any, true>
---@field lhs?        string[]
---@field mode        string[]
---@field opts        vim.keymap.set.Opts
---@field rhs?        string|function
---@field suffix?     string
---@field event?      string[]
---@field pattern?    string[]
---@field buffer?     boolean
---@field once?       boolean
---@field prefix?     string
---@field index?      any[]
---@field value?      any
---@field key_as_lhs? boolean

local Spec={}
--- 将原始规范转换为处理后的规范
---@param raw_spec RawSpec
---@return Spec
function Spec.new(raw_spec)
 local spec={}
 -- meta
 spec.cond=raw_spec.cond or true
 spec.fallback=raw_spec.fallback or false
 spec.lazykey=raw_spec.lazykey or true
 spec.name=raw_spec.name
 spec.priority=raw_spec.priority or 0
 spec.tags=Util.tbl_to_set(Util.totable(raw_spec.tags))
 -- basic
 if raw_spec.cmd then
  spec.rhs="<cmd>"..raw_spec.cmd.."<cr>"
 else
  spec.rhs=raw_spec.rhs
 end
 spec.mode=raw_spec.mode and Util.to_fat_table(raw_spec.mode) or {"n"}
 if raw_spec.lhs then
  local lhs={}
  for _,l in Util.pipairs(raw_spec.lhs) do
   table.insert(lhs,Util.concat(raw_spec.prefix,l,raw_spec.suffix))
  end
  spec.lhs=Util.to_fat_table(lhs)
 end
 local desc=raw_spec.desc
  or (raw_spec.name and Util.I18n.get({"mapdesc",raw_spec.name})
   or tostring(raw_spec.rhs))
 spec.opts=Util.tbl_extend({},{noremap=true,silent=true},raw_spec.opts or {},{desc=desc})
 -- autocmd
 spec.event=Util.to_fat_table(raw_spec.event)
 spec.pattern=Util.to_fat_table(raw_spec.pattern)
 spec.buffer=raw_spec.buffer
 spec.once=raw_spec.once
 -- options
 spec.prefix=raw_spec.prefix or ""
 spec.suffix=raw_spec.suffix or ""
 local index; index=raw_spec.index
 if type(index)=="string" then
  index=Util.concat(spec.prefix,index,spec.suffix)
  index=vim.split(index,".",{plain=true})
 end
 spec.index=index
 spec.value=raw_spec.value
 spec.key_as_lhs=raw_spec.key_as_lhs or false
 return spec
end
---@class Mapping
local Mapping={
 spec=nil, ---@type Spec
 instances={},
 autocmd_id=nil, ---@type nil|integer
}
--- mapping class
---@param spec Spec
---@return Mapping
function Mapping.new(spec)
 local obj=setmetatable({},{__index=Mapping})
 obj.spec=spec
 obj.instances={}
 obj.autocmd_id=nil
 return obj
end
function Mapping:is_keymap()
 local spec=self.spec
 return spec.lhs~=nil and spec.rhs~=nil
end
function Mapping:is_autocmd()
 local spec=self.spec
 return spec.event~=nil or spec.pattern~=nil
end
function Mapping:is_config()
 local spec=self.spec
 return spec.index~=nil or spec.value~=nil
end
function Mapping:is_active()
 return self.autocmd_id~=nil or next(self.instances)~=nil
end
---@param mapping Mapping
function Mapping:override(mapping)
 if mapping.spec.priority<self.spec.priority then
  return
 end
 local active=self:is_active()
 if active then
  self:stop()
 end
 Util.tbl_deep_extend(self.spec,mapping.spec)
 if active then
  self:create()
 end
end
function Mapping:check()
 local spec=self.spec
 return Util.toboolean(Util.eval(spec.cond))
end
---@param buffer integer|boolean?
function Mapping:create(buffer)
 if self:check()==false then
  return
 end
 local spec=self.spec
 if self:is_autocmd() then
  local event=spec.event or "FileType"
  self.autocmd_id=api.nvim_create_autocmd(event,{
   pattern=spec.pattern,
   once=spec.once,
   callback=function(ev)
    self:_create(spec.buffer and ev.buf or nil)
   end,
  })
  return
 end
 self:_create(buffer)
end
function Mapping:stop()
 if self.autocmd_id~=nil then
  api.nvim_del_autocmd(self.autocmd_id)
  self.autocmd_id=nil
 end
 self:delete()
end
---@param buffer integer|boolean?
function Mapping:_create(buffer)
 local spec=self.spec
 if not self:is_keymap() or self:is_config() then
  return
 end
 if buffer==nil then
  buffer=spec.buffer
 end
 if buffer~=nil then
  buffer=resolve_buffer(buffer)
 end
 keymap_set(buffer,spec.mode,spec.lhs,spec.rhs,spec.opts,spec.fallback)
 table.insert(self.instances,{buffer,spec.mode,spec.lhs})
end
function Mapping:delete()
 if next(self.instances)==nil then
  return
 end
 for _,spec in ipairs(self.instances) do
  local buffer,mode,lhs=spec[1],spec[2],spec[3]
  keymap_del(buffer,mode,lhs)
 end
 self.instances={}
end
function Mapping:configure(opts)
 local spec=self.spec
 if self:is_config() then
  Util.tbl_set(opts,spec.index,spec.value)
 end
end
function Mapping:is_lazykey()
 local spec=self.spec
 return spec.lazykey and (spec.name~=nil or spec.index~=nil or spec.value~=nil or next(spec.tags)~=nil)
end
function Mapping:lazykeys()
 local spec=self.spec
 if not self:is_lazykey() then
  return
 end
 local keys
 if spec.lhs~=nil then
  keys=spec.lhs
 elseif self:is_config() then
  if spec.key_as_lhs==true then
   keys=spec.index[#spec.index]
  else
   keys=spec.value
  end
 end
 if keys==nil then
  return
 end
 local ret={}
 for _,v in Util.pipairs(keys) do
  ---@type {}
  local base=vim.deepcopy(spec.opts)
  base[1]=v
  base.mode=spec.mode
  table.insert(ret,base)
 end
 return ret
end
---@class Interface
local Interface={
 ---@type table<any, Mapping[]>
 index={},
 ---@type table<any, Mapping>
 mappings={},
}
Interface.wkspec={}
---@return Interface
function Interface.new()
 local obj=setmetatable({},{__index=Interface})
 obj.index={}
 obj.mappings={}
 return obj
end
---@param tag any
---@return Interface
function Interface:export(tag)
 local obj=Interface.new()
 if tag then
  local mappings=self.index[tag]
  obj.index[tag]=mappings
  obj.mappings=mappings
 end
 return obj
end
---@alias RawSpecs RawSpec|RawSpec[]
---@param raw_specs RawSpecs
---@param func fun(spec: RawSpec)
function Interface.forspecs(raw_specs,func)
 local wkspec=raw_specs.wkspec
 if wkspec then
  table.insert(Interface.wkspec,wkspec)
 end
 if raw_specs[1]~=nil then
  for _,raw_spec in ipairs(raw_specs) do
   if raw_specs.override then
    raw_spec.override=Util.tbl_deep_extend(raw_spec.override or {},raw_specs.override)
   end
   Interface.forspecs(raw_spec,func)
  end
 else
  if raw_specs.override then
   Util.tbl_deep_extend(raw_specs,raw_specs.override)
  end
  func(raw_specs)
 end
end
function Interface:formaps(func)
 for _,mapping in pairs(self.mappings) do
  func(mapping)
 end
end
---@param raw_spec RawSpec
function Interface:add(raw_spec)
 local spec=Spec.new(raw_spec)
 local mappings=self.mappings
 local mapping=Mapping.new(spec)
 --- override
 local name=spec.name
 if name then
  local exist=mappings[name]
  if exist then
   exist:override(mapping)
   mapping=exist
  end
 end
 --- add
 local key=name or #mappings+1
 mappings[key]=mapping
 --- tag
 if next(spec.tags)~=nil then
  local index=self.index
  for tag in pairs(spec.tags) do
   Util.tbl_set(index,{tag,key},mapping)
  end
 end
 return mapping
end
---@param raw_specs RawSpec
function Interface:extend(raw_specs)
 Interface.forspecs(raw_specs,function(spec)
  self:add(spec)
 end)
 return self
end
---@param buffer integer|boolean?
function Interface:create(buffer)
 for _,mapping in pairs(self.mappings) do
  mapping:create(buffer)
 end
end
function Interface:delete()
 for _,mapping in pairs(self.mappings) do
  mapping:delete()
 end
end
---@param opts table
function Interface:configure(opts)
 for _,mapping in pairs(self.mappings) do
  mapping:configure(opts)
 end
 return opts
end
function Interface:lazykeys(tbl)
 if tbl==nil then
  tbl={}
 end
 for _,mapping in pairs(self.mappings) do
  local lazykey=mapping:lazykeys()
  if lazykey then
   Util.list_extend(tbl,lazykey)
  end
 end
 return tbl
end
return Interface
