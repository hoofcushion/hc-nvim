local api=vim.api
local Util=require("hc-nvim.util")
--- custom mapping util
local Keymap={}
---@param mode string
---@param lhs string
---@param rhs string
---@param opts vim.api.keyset.keymap
---@param buffer integer?
local function set(buffer,mode,lhs,rhs,opts)
 --- HACK: Work-around for nvim_buf_del_keymap
 rhs=rhs.."<ignore>"
 if buffer~=nil then
  api.nvim_buf_set_keymap(buffer,mode,lhs,rhs,opts)
  return
 end
 api.nvim_set_keymap(mode,lhs,rhs,opts)
end
local function mkp(buffer,m,l,r,opts)
 local cb=opts.callback
 opts.callback=function()
  return cb(l)
 end
end
local function mkfb(buffer,m,l,r,opts)
 local keys=api.nvim_replace_termcodes(l,true,false,true)
 local cb=opts.callback
 opts.callback=function()
  local ret=cb()
  if not ret then
   api.nvim_feedkeys(keys,"n",false)
  end
 end
end
---@param buffer integer?
---@param mode string|string[]
---@param lhs string|string[]
---@param rhs string|function
---@param opts vim.keymap.set.Opts
---@param fallback boolean?
function Keymap.set(buffer,mode,lhs,rhs,opts,fallback)
 if opts.expr==true and opts.replace_keycodes==nil then
  opts.replace_keycodes=true
 end
 if opts.remap~=nil then
  opts.remap=nil
  opts.noremap=not opts.remap
 end
 for _,l in Util.pipairs(lhs) do
  for _,m in Util.pipairs(mode) do
   local r=rhs
   if type(r)=="function" then
    opts.callback=r
    r=""
   end
   if opts.callback then
    if opts.expr then
     mkp(buffer,m,l,r,opts)
    end
    if fallback then
     mkfb(buffer,m,l,r,opts)
    end
   end
   set(buffer,m,l,r,opts)
  end
 end
end
local function del(buffer,mode,lhs)
 if buffer~=nil then
  api.nvim_buf_del_keymap(buffer,mode,lhs)
  return
 end
 api.nvim_del_keymap(mode,lhs)
end
---@param buffer integer?
---@param mode string|string[]
---@param lhs string|string[]
function Keymap.del(buffer,mode,lhs)
 for _,l in Util.pipairs(lhs) do
  for _,m in Util.pipairs(mode) do
   pcall(del,buffer,m,l)
  end
 end
end
---@class mapspec
---@field override mapspec?
---@field [integer] mapspec?
local Mapspec={
 wkspec={}, ---@type table
 ---
 cond=nil, ---@type nil|function|boolean
 fallback=nil, ---@type nil|boolean
 lazykey=nil, ---@type nil|boolean
 name=nil, ---@type nil|any
 priority=nil, ---@type nil|integer
 tags=nil, ---@type nil|any|any[]
 ---
 desc=nil, ---@type nil|string
 cmd=nil, ---@type nil|string
 lhs=nil, ---@type nil|string[]
 mode=nil, ---@type nil|string|string[]
 opts=nil, ---@type nil|vim.keymap.set.Opts
 rhs=nil, ---@type nil|string|function
 suffix=nil, ---@type nil|string
 ---
 event=nil, ---@type nil|string|string[]
 pattern=nil, ---@type nil|string|string[]
 buffer=nil, ---@type nil|boolean
 once=nil, ---@type nil|boolean
 ---
 prefix=nil, ---@type nil|string
 index=nil, ---@type nil|string
 value=nil, ---@type nil|any
 key_as_lhs=false, ---@type nil|boolean
}
---@class Mapping
local Mapping={
 cond=true, ---@type function|boolean # whether or not to create mapping
 name=nil, ---@type any # name to identify mapping
 priority=0, ---@type integer # priority to decide whether it should be overridden
 tags={}, ---@type table<any,true> # tags to identify mapping
 lazykey=true, ---@type boolean
 instances={},
 ---
 fallback=false, ---@type nil|boolean # fallback to fallbacks when rhs evals to false value
 lhs=nil, ---@type nil|string[] # left-hand side of mapping
 mode={"n"}, ---@type nil|string|string[] # mode of mapping
 opts={noremap=true,silent=true}, ---@type vim.keymap.set.Opts # options for mapping
 rhs=nil, ---@type nil|string|function # right-hand side of mapping
 ---
 autocmd_id=nil, ---@type nil|integer # autocmd id
 event=nil, ---@type nil|string[] # event for buflocal mapping
 pattern=nil, ---@type nil|string[] # pattern for buflocal mapping
 buffer=nil, ---@type nil|boolean # whether or not to be buffer local mapping for autocmd mapping
 once=nil, ---@type nil|boolean # autocmd only trigger once
 ---
 key_as_lhs=false, ---@type boolean # whether or not to use key as lhs, else use value
 index=nil, ---@type nil|string # index path for plugin options
 value=nil, ---@type nil|any # value for plugin options
}
--- mapping class
--- support:
---  multiple lhs
---  convert spec to lazykey
---  fallback rhs
---  autocmd mapping (e.g. FileType)
---  declare & define separated
---  configure plugin options
---  condition
---@param spec mapspec
---@return Mapping
function Mapping.new(spec)
 local obj=Util.Class.new(Mapping)
 obj.instances={}
 obj.cond=spec.cond
 obj.lazykey=spec.lazykey
 obj.name=spec.name
 obj.priority=spec.priority
 obj.fallback=spec.fallback

 if not Util.is_empty(spec.tags) then
  local tags=Util.to_fat_table(spec.tags)
  obj.tags=Util.tbl_to_set(tags)
 end
 
 if spec.index then
  obj.key_as_lhs=spec.key_as_lhs
  obj.index=spec.index~=nil and Util.concat(spec.prefix,spec.index,spec.suffix) or nil
  obj.value=spec.value
 end

 if spec.mode then
  obj.mode=Util.to_fat_table(spec.mode)
 end

 if spec.lhs then
  local lhs={}
  for _,l in Util.pipairs(spec.lhs) do
   table.insert(lhs,Util.concat(spec.prefix,l,spec.suffix))
  end
  obj.lhs=Util.to_fat_table(lhs)
 end

 if spec.rhs or spec.cmd then
  obj.rhs=spec.rhs or spec.cmd and ("<cmd>"..spec.cmd.."<cr>")
 end

 obj.opts=spec.opts and Util.tbl_extend({},Mapping.opts,spec.opts) or Util.deepcopy(Mapping.opts)
 local desc=spec.desc or Util.I18n.get("mapdesc",obj.name) or (tostring(obj.rhs))
 obj.opts.desc=desc

 if spec.event or spec.pattern then
  obj.event=Util.to_fat_table(spec.event)
  obj.pattern=Util.to_fat_table(spec.pattern)
  obj.buffer=spec.buffer
  obj.once=spec.once
 end

 return obj
end
function Mapping:is_autocmd()
 return self.event~=nil or self.pattern~=nil
end
function Mapping:is_config()
 return self.index~=nil or self.value~=nil
end
function Mapping:is_active()
 return self.autocmd_id~=nil or next(self.instances)~=nil
end
function Mapping:is_lazykey()
 return self.lazykey and vim.F.if_nil(self.name,self.index,self.value,self.tags)~=nil
end
---@param mapping Mapping
function Mapping:override(mapping)
 if mapping.priority<self.priority then
  return
 end
 local active=self:is_active()
 if active then
  self:stop()
 end
 Util.tbl_deep_extend(self,mapping)
 if active then
  self:start()
 end
end
function Mapping:check()
 return Util.toboolean(Util.eval(self.cond))
end
---@param buffer integer|boolean?
function Mapping:start(buffer)
 if self:check()==false then
  return
 end
 if self:is_autocmd() then
  local event=self.event or "FileType"
  self.autocmd_id=api.nvim_create_autocmd(event,{
   pattern=self.pattern,
   once=self.once,
   callback=function(ev)
    self:set(self.buffer and ev.buf or nil)
   end,
  })
  --- WARN: Will trigger other filetype autocmds
  if event=="FileType" and vim.bo.filetype~="" then
   vim.bo.filetype=vim.bo.filetype
  end
  return
 end
 self:set(buffer)
end
function Mapping:stop()
 if self.autocmd_id~=nil then
  api.nvim_del_autocmd(self.autocmd_id)
 end
 self:del()
end
---@param buffer integer|boolean?
function Mapping:set(buffer)
 if self:is_config() then
  return
 end
 local lhs=self.lhs
 if lhs==nil then return end
 local rhs=self.rhs
 if rhs==nil then return end
 if buffer~=nil then
  if buffer==false then buffer=nil end
  if buffer==true then buffer=0 end
 end
 Keymap.set(
  buffer,
  self.mode,
  lhs,
  rhs,
  self.opts,
  self.fallback
 )
 self.instances[{}]={buffer,self.mode,lhs}
end
function Mapping:del()
 if next(self.instances)==nil then
  return
 end
 for _,spec in pairs(self.instances) do
  local buffer,mode,lhs=spec[1],spec[2],spec[3]
  Keymap.del(
   buffer,
   mode,
   lhs
  )
 end
 self.instances={}
end
function Mapping:configure(opts)
 if self:is_config() then
  Util.tbl_set(opts,self.index,self.value)
 end
end
function Mapping:lazyexport()
 if not self:is_lazykey() then
  return
 end
 local lhs
 if self.lhs~=nil then
  lhs=self.lhs
 elseif self:is_config() then
  if self.key_as_lhs==true then
   lhs=string.match(self.index,"[^.]+$")
  else
   lhs=self.value
  end
 end
 if lhs==nil then
  return
 end
 local ret={}
 for _,v in Util.pipairs(lhs) do
  local base={}
  Util.override(base,self.opts)
  base[1]=v
  base.mode=self.mode
  table.insert(ret,base)
 end
 return ret
end
---@class KeymapInterface
local Interface={
 ---@type table<any,Mapping[]>
 index={},
 ---@type table<any,Mapping>
 mappings={},
}
Interface.wkspec={}
---@param mapspecs mapspec?
function Interface.new(mapspecs)
 local obj=Util.Class.new(Interface)
 obj.index={}
 obj.mappings={}
 if mapspecs~=nil then
  obj:extend(mapspecs)
 end
 return obj
end
---@param tag any
function Interface:export(tag)
 local obj=Interface.new()
 if tag then
  local mappings=self.index[tag]
  obj.index[tag]=mappings
  obj.mappings=mappings
 end
 return obj
end
---@param mapspecs mapspec
---@param func fun(mapspec:mapspec)
function Interface.forspecs(mapspecs,func)
 local wkspec=mapspecs.wkspec
 if wkspec then
  table.insert(Interface.wkspec,wkspec)
 end
 if mapspecs[1]~=nil then
  for _,mapspec in ipairs(mapspecs) do
   if mapspec.override or mapspecs.override then
    mapspec.override=Util.tbl_deep_extend({},mapspec.override,mapspecs.override)
   end
   Interface.forspecs(mapspec,func)
  end
 else
  if mapspecs.override then
   Util.tbl_deep_extend(mapspecs,mapspecs.override)
  end
  func(mapspecs)
 end
end
function Interface:formaps(func)
 for _,mapping in pairs(self.mappings) do
  func(mapping)
 end
end
---@param mapspec mapspec
function Interface:add(mapspec)
 local mappings=self.mappings
 local s=Util.clock()
 local mapping=Mapping.new(mapspec)
 local e=Util.clock()
 a=(a or 0)+(e-s)
 --- override
 local name=mapping.name
 if name then
  local exist=mappings[name]
  if exist~=nil then
   exist:override(mapping)
   mapping=exist
  end
 end
 --- add
 local key=name or #mappings+1
 mappings[key]=mapping
 --- tag
 if mapping.tags then
  local index=self.index
  for tag in pairs(mapping.tags) do
   Util.tbl_newindex(index,tag,key,mapping)
  end
 end
 return mapping
end
---@param mapspecs mapspec
function Interface:extend(mapspecs)
 Interface.forspecs(mapspecs,function(mapspec)
  self:add(mapspec)
 end)
 return self
end
---@param buffer integer|boolean?
function Interface:create(buffer)
 local mappings=self.mappings
 for _,mapping in pairs(mappings) do
  mapping:start(buffer)
 end
end
function Interface:delete()
 local mappings=self.mappings
 for _,mapping in pairs(mappings) do
  mapping:del()
 end
end
---@param opts table
function Interface:configure(opts)
 local mappings=self.mappings
 for _,mapping in pairs(mappings) do
  mapping:configure(opts)
 end
 return opts
end
function Interface:lazykeys(tbl)
 if tbl==nil then
  tbl={}
 end
 local mappings=self.mappings
 for _,mapping in pairs(mappings) do
  local lazykey=mapping:lazyexport()
  if lazykey then
   Util.list_extend(tbl,lazykey)
  end
 end
 return tbl
end
return Interface
