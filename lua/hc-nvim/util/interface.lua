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

local function handle(err) vim.notify(err,vim.log.levels.ERROR) end
local function try(fn) xpcall(fn,handle) end

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
   try(function() _set(buffer,_mode,_lhs,_rhs,opts) end)
  end
 end
end

---@param buffer integer?
---@param mode string|string[]
---@param lhs string|string[]
local function keymap_del(buffer,mode,lhs)
 for _,l in Util.pipairs(lhs) do
  for _,m in Util.pipairs(mode) do
   try(function() _del(buffer,m,l) end)
  end
 end
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
---@field event? vim.api.keyset.events|vim.api.keyset.events[]
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
---@field event?      vim.api.keyset.events[]
---@field pattern?    string[]
---@field buffer     boolean
---@field once       boolean
---@field prefix?     string
---@field index?      any[]
---@field value?      any
---@field key_as_lhs boolean

local Spec={
 mode={"n"},
 tags={},
 cond=true,
 fallback=false,
 lazykey=true,
 priority=0,
 buffer=false,
 once=false,
 key_as_lhs=false,
}
local function get_desc(name)
 local map=Util.I18n.map
 local trans=map.mapdesc[name]
 if trans then
  return trans:get()
 end
end
local _Spec={__index=Spec}
--- 将原始规范转换为处理后的规范
---@param raw RawSpec
---@return Spec
function Spec.new(raw)
 local spec=setmetatable({},_Spec)
 -- meta
 if raw.cond~=nil then spec.cond=raw.cond end
 if raw.fallback~=nil then spec.fallback=raw.fallback end
 if raw.lazykey~=nil then spec.lazykey=raw.lazykey end
 if raw.name~=nil then spec.name=raw.name end
 if raw.priority~=nil then spec.priority=raw.priority end
 if raw.tags~=nil then
  spec.tags=Util.tbl_to_set(Util.totable(raw.tags))
 end
 -- basic
 if raw.cmd~=nil then
  spec.rhs="<cmd>"..raw.cmd.."<cr>"
 else
  if raw.rhs~=nil then spec.rhs=raw.rhs end
 end
 if raw.mode~=nil then
  spec.mode=Util.totable(raw.mode)
 end
 local prefix=raw.prefix
 local suffix=raw.suffix
 if raw.lhs~=nil then
  local lhs={}
  for _,l in Util.pipairs(raw.lhs) do
   table.insert(lhs,Util.concat(prefix,l,suffix))
  end
  spec.lhs=Util.try_to_list_else_nil(lhs)
 end
 local desc=raw.desc or (get_desc(raw.name))
 spec.opts={noremap=true,silent=true,desc=desc}
 if raw.opts~=nil then
  spec.opts=Util.tbl_extend(spec.opts,raw.opts)
 end
 -- autocmd
 if raw.event~=nil then spec.event=Util.totable(raw.event) end
 if raw.pattern~=nil then spec.pattern=Util.totable(raw.pattern) end
 if raw.buffer~=nil then spec.buffer=raw.buffer end
 if raw.once~=nil then spec.once=raw.once end
 -- options
 local index
 if raw.index~=nil then index=raw.index end
 if type(index)=="string" then
  index=Util.concat(prefix,index,suffix)
  index=vim.split(index,".",{plain=true})
 end
 if index~=nil then spec.index=index end
 if raw.value~=nil then spec.value=raw.value end
 if raw.key_as_lhs~=nil then spec.key_as_lhs=raw.key_as_lhs end
 return spec
end
---@class Mapping
local Mapping={
 spec=nil, ---@type Spec
 instances=nil, ---@type {[1]:integer,[2]:string,[3]:string}[]
 autocmd_id=nil, ---@type integer?
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
  self:delete()
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
function Mapping:_create(buffer)
 local spec=self.spec
 if not self:is_keymap() or self:is_config() then
  return
 end
 if buffer==nil then
  buffer=spec.buffer
 end
 -- ignore nil|false
 if not buffer then
  buffer=nil
 end
 -- true -> current buf
 if buffer==true then
  buffer=0
 end
 -- resolve current buf
 if buffer==0 then
  buffer=vim.api.nvim_get_current_buf()
 end
 keymap_set(buffer,spec.mode,spec.lhs,spec.rhs,spec.opts,spec.fallback)
 table.insert(self.instances,{buffer,spec.mode,spec.lhs})
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
function Mapping:delete()
 if self.autocmd_id~=nil then
  try(function() api.nvim_del_autocmd(self.autocmd_id) end)
  self.autocmd_id=nil
 end
 if next(self.instances)~=nil then
  for _,spec in ipairs(self.instances) do
   local buffer,mode,lhs=spec[1],spec[2],spec[3]
   keymap_del(buffer,mode,lhs)
  end
  self.instances={}
 end
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
  table.insert(ret,{v,mode=spec.mode,desc=spec.opts.desc})
 end
 return ret
end
---@class Interface
local Interface={
 index={}, ---@type table<any, Mapping[]>
 mappings={}, ---@type table<any, Mapping>
}
Interface.wkspec={}
local _Interface={__index=Interface}
---@return Interface
function Interface.new()
 local obj=setmetatable({},_Interface)
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
---@param raw RawSpecs
---@param func fun(spec: RawSpec)
function Interface.forspecs(raw,func)
 if raw.wkspec then
  table.insert(Interface.wkspec,raw.wkspec)
 end
 if raw[1]~=nil then
  for _,raw_spec in ipairs(raw) do
   Interface.forspecs(raw_spec,func)
  end
 else
  func(raw)
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
