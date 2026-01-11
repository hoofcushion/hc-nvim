local function packlen(...)
 return {n=select("#",...),...}
end
local function unpacklen(pack)
 return unpack(pack,1,pack.n)
end
---@class Response
local Response={}
Response.__index=Response
Response.v=function() end ---@type function
Response.cached=nil
function Response:get()
 return self:v()
end
function Response:get_cached()
 local cache=self.cached
 if not cache then
  cache=packlen(self:v())
  self.cached=cache
 end
 return unpacklen(self.cached)
end
---@param f function
function Response:set(f)
 self.v=f
end
---@private
function Response:_extract()
 return unpacklen(self.args)
end
function Response:set_from(...)
 self.args=packlen(...)
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
    response.cached=nil
   end
  end,
 })
 return function()
  return response:get_cached()
 end
end
return Response
