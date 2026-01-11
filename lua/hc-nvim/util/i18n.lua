local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util.init_space")
---@class I18nSpec
local I18nSpec={
 language="en",
 country="US",
 ---@class I18nSpec.translations
 ---@field [string] string|I18nSpec.translations
 translations={
  greet="嗨",
  msg={
   hello="你好",
  },
 },
}
---@class Translation
local Translation={
 ---@type table<string,Translation>
 map={},
}
Translation.__index=Translation
function Translation.new()
 local obj=setmetatable({},Translation)
 obj.map={}
 return obj
end
function Translation:get()
 for _,locale in ipairs(Config.locale.fallbacks) do
  local ret=Util.tbl_get(self.map,{locale.language,locale.country})
  if ret then
   return ret
  end
 end
end
function Translation:format(...)
 return self:get():format(...)
end
local function extend(ret,language,country,translations)
 if type(translations)=="table" then
  for k,translation in pairs(translations) do
   local t=ret.map[k]
   if not t then
    t=Translation.new()
    ret.map[k]=t
   end
   extend(t,language,country,translation)
  end
 elseif type(translations)=="string" then
  Util.tbl_check(ret.map,language)[country]=translations
 else
  vim.notify("Invalid translation type",vim.log.levels.WARN)
 end
 return ret
end
---@param spec I18nSpec
function Translation:load(spec)
 extend(
  self,
  spec.language,
  spec.country,
  spec.translations
 )
end
function Translation:tbl_get(keys)
 local trans=self
 for _,key in ipairs(keys) do
  trans=trans.map[key]
  if not trans then
   error(table.concat(keys,"."))
  end
 end
 if trans then
  return trans:get()
 end
end
if LUAFILE then
 local i18n=Translation.new()
 i18n:load(I18nSpec)
 vim.print(i18n.map.greet:get())
 vim.print(i18n.map.msg.map.hello:format())
end
return Translation
