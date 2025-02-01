local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
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
 ---@type table<string,table<string,string>>
 map={},
}
function Translation.new()
 return Util.Class.new(Translation)
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
   local t=Util.tbl_check(ret,k,function ()
    return {map={}}
   end)
   extend(t,language,country,translation)
  end
 elseif type(translations)=="string" then
  Util.tbl_check(ret.map,language)[country]=translations
  Util.Class.set(ret,Translation)
 else
  vim.notify("Invalid translation type",vim.log.levels.WARN)
 end
 return ret
end
local I18n={
 map={},
}
---@param spec I18nSpec
function I18n.load(spec)
 assert(type(spec)=="table","Expect table")
 extend(
  I18n.map,
  spec.language,
  spec.country,
  spec.translations
 )
end
function I18n.get(keys)
 local trans=Util.tbl_get(I18n.map,keys)
 if trans then
  return trans:get()
 end
end
return I18n
