local Util=require("hc-nvim.util.init_space")
---@alias Autocmd.param {[1]:vim.api.keyset.events|vim.api.keyset.events[],[2]:vim.api.keyset.create_autocmd}

---@class Autocmd
local Autocmd={
 active=false, ---@type boolean
 attached_bufs={}, ---@type table<integer,boolean>
 buffer=false, ---@type boolean
 ids={}, ---@type table<integer,boolean>
 params={}, ---@type Autocmd.param[]
}
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
function Autocmd:buf_extend(buffers,is_map)
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
function Autocmd:buf_fini()
 self.buffer=false
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
---@param params Autocmd.param[]
function Autocmd:add(params)
 for _,param in ipairs(params) do
  -- do decor
  pcall(function()
   local opts=param[2]
   assert(type(opts)=="table")
   assert(type(opts.callback)=="function")
   opts.callback=self:cb_decor(opts.callback)
  end)
  table.insert(self.params,param)
 end
 return self
end
function Autocmd:enable()
 for _,p in ipairs(self.params) do
  local id=vim.api.nvim_create_autocmd(p[1],p[2])
  self.ids[id]=true
 end
 return self
end
function Autocmd:disable()
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
 self.active=false
 self.attached_bufs={}
 self.buffer=false
 self.ids={}
 self.params={}
 return self
end
function Autocmd.new()
 local obj=setmetatable({},{__index=Autocmd})
 obj.active=false
 obj.attached_bufs={}
 obj.buffer=false
 obj.ids={}
 obj.params={}
 return obj
end
return Autocmd
