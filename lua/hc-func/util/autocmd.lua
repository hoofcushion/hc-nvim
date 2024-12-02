local Class=require("hc-func.class")
---@class Autocmd
local Autocmd={
 active       =false, ---@type boolean
 buffer       =false, ---@type boolean
 attached_bufs={}, ---@type table<integer,boolean>
 ids          ={}, ---@type table<integer,boolean>
 params       ={}, ---@type {[1]:string|string[],[2]:table}[]
}
---@param opts Autocmd?
function Autocmd.new(opts)
 local obj=Class.new(Autocmd)
 obj.attached_bufs={}
 obj.ids={}
 obj.params={}
 if opts then
  for k,v in pairs(opts) do
   obj[k]=v
  end
 end
 return obj
end
---@param opts Autocmd
function Autocmd:set(opts)
 return Class.new(self,opts)
end
---@private
function Autocmd:cb_decor(callback)
 return function(event)
  if self.active==false then
   return
  end
  if self.buffer==true then
   local buf=event.buf
   local attached_bufs=self.attached_bufs
   if attached_bufs[buf]==nil then
    return
   end
  end
  return callback(event)
 end
end
function Autocmd:buf_add(buffers,is_map)
 local attacheds=self.attached_bufs
 if is_map then
  for buf in pairs(buffers) do
   attacheds[buf]=true
  end
 else
  for _,buf in ipairs(buffers) do
   attacheds[buf]=true
  end
 end
 return self
end
function Autocmd:buf_attach(buf)
 self.attached_bufs[buf]=true
 return self
end
function Autocmd:buf_detach(buf)
 self.attached_bufs[buf]=nil
 return self
end
function Autocmd:buf_clear()
 self.attached_bufs={}
 return self
end
function Autocmd:buf_activate()
 self.buffer=true
 return self
end
function Autocmd:buf_deactivate()
 self.buffer=false
 return self
end
function Autocmd:buf_toggle()
 self.buffer=not self.buffer
 return self
end
function Autocmd:buf_fini()
 self.bufffer=false
 self.attached_bufs={}
 return self
end
function Autocmd:activate()
 self.active=true
 return self
end
function Autocmd:deactivate()
 self.active=false
 return self
end
function Autocmd:toggle()
 self.active=not self.active
 return self
end
function Autocmd:add(params)
 for _,param in ipairs(params) do
  local opts=param[2]
  if opts~=nil then
   local callback=opts.callback
   if callback~=nil then
    opts.callback=self:cb_decor(callback)
   end
  end
  table.insert(self.params,param)
 end
 return self
end
function Autocmd:create()
 for _,param in ipairs(self.params) do
  local id=vim.api.nvim_create_autocmd(param[1],param[2])
  self.ids[id]=true
 end
 return self
end
function Autocmd:delete()
 for id in pairs(self.ids) do
  vim.api.nvim_del_autocmd(id)
 end
 self.ids={}
 return self
end
function Autocmd:fini()
 for id in pairs(self.ids) do
  vim.api.nvim_del_autocmd(id)
 end
 self.ids={}
 self.params={}
 self.attached_bufs={}
 self.active=false
 return self
end
return Autocmd
