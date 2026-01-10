---@class Response
local Response={}
Response.__index=Response
Response.v=function() end ---@type function
function Response:get()
 return self:v()
end
---@param f function
function Response:set(f)
 self.v=f
end
---@private
function Response:_extract()
 return unpack(self.args,1,self.n)
end
function Response:set_from(...)
 self.n=select("#",...)
 self.args={...}
 self.v=Response._extract
end
function Response.new()
 return setmetatable({},Response)
end
---@generic T
---@param opts {
--- event:vim.api.keyset.events|vim.api.keyset.events[]|string|string[],
--- filter:(fun(data):boolean),
--- func:T,
--- pattern:string?,
---}
---@return T
function Response.from_event(opts)
 local response=Response.new()
 vim.api.nvim_create_autocmd(opts.event,{
  pattern=opts.pattern,
  callback=function(data)
   if opts.filter==nil or opts.filter(data) then
    response:set_from(opts.func())
   end
  end,
 })
 return function()
  return response:get()
 end
end
return Response
