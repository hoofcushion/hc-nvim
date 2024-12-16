local M={}
---@param lang string
local function get_locale(lang)
 local s=lang:find(".",1,true) -- remove encoding
 if s then
  lang=lang:sub(1,s-1)
 end
 local language,country=string.match(lang,"^(.-)_(.-)$")
 return {
  language=language,
  country=country,
  code=lang,
 }
end
M.locale={
 current=get_locale(os.setlocale(nil,"ctype")),
 default=get_locale("en_US"),
}
M.locale.fallbacks={
 M.locale.current,
 M.locale.default,
}
local uname=vim.uv.os_uname()
M.platform={
 uname=uname,
 is_windows=uname.sysname:find("Windows",nil,true)~=nil,
 is_gui=vim.fn.has("gui_running"),
 is_vscode=vim.g.vscode==1,
 is_neovide=vim.g.neovide==1,
}
M.ui={
 ---@type
 ---| "icon"   # iconic text
 ---| "letter" # letter-based text
 ---| "hanzi"  # Chinese characters
 ---| "none"   # no icon or text
 sign=M.locale.current.language=="zh" and "hanzi" or "icon",
 ---@type
 ---| "icon"    # iconic text
 ---| "letter"  # letter-based text
 ---| "hanzi"   # Chinese characters
 ---| "none"    # no icon or text
 kind=M.locale.current.language=="zh" and "hanzi" or "icon",
 ---@type
 ---| "none"    # no border
 ---| "single"  # single line border
 ---| "thick"   # single line border heavier
 ---| "double"  # double line border
 ---| "rounded" # round corner
 ---| "solid"   # padding by whitespace
 ---| "shadow"  # shadow effect
 ---| "block"   # block border
 border="single",
 window={
  -- side window
  vertical=0.25,
  horizontal=0.25,
  -- float window
  width=0.75,
  height=0.75,
  dynamic=(function()
   local is_width={vertical=true,width=true}
   ---@param direction "horizontal"|"vertical"|"width"|"height"
   return function(self,direction)
    local factor=self[direction]
    if factor==nil then
     error("Direction invalid: "..tostring(direction))
    end
    local size=is_width[direction] and vim.o.columns or vim.o.lines
    return math.ceil(factor*size)
   end
  end)(),
  ---@type table<"horizontal"|"vertical"|"width"|"height",string>
  percentage=setmetatable({},{
   __index=function(_,k)
    local factor=M.ui.window[k]
    return string.format("%d%%",factor*100)
   end,
  }),
 },
}
M.performance={
 refresh=500,
 throttle=100,
 plugin={
  --- Duration (ms) to wait, when loading plugin continuously.
  --- Set to 0 to disable.
  load_cooldown=1,
 },
 --- How a file recognize as a bigfile.
 --- Lsp and treesitter will not attach it for performance.
 bigfile={
  lines=1024*10,
  bytes=1024^2,
 },
 exclude={
  filetypes={
   "bigfile",
  },
  buftypes={
   "terminal",
   "nofile",
   "quickfix",
   "prompt",
  },
 },
}
--- spec[1] is the mason name of the server, specify it to download the server.
--- spec[2] is the setup name for the server, specify it to setup the server.
--- e.g, lua language server has name lua-language-server as mason package, but lua_ls in nvim-lspconfig's setup function.
M.server={
 vscode=false,
 ensure_installed=true,
 auto_update=true,
 auto_setup=true,
 list={
  --- lspconfig
  {name="ast-grep",            setup="ast_grep"},
  {name="bash-language-server",setup="bashls"},
  {name="clangd"},
  {name="deno",                setup="denols"},
  {name="json-lsp",            setup="jsonls"},
  {name="lua-language-server", setup="lua_ls"},
  {name="marksman"},
  {name="pyright"},
  {name="rust-analyzer",       setup="rust_analyzer"},
  {name="taplo"},
  {name="vim-language-server", setup="vimls"},
  {name="vls"},
  {name="yaml-language-server",setup="yamlls"},
  {name="zk"},
  {name="zls"},
  --- null-ls
  {name="cbfmt"},
  {name="prettier"},
  {name="stylua",              setup="formatting.stylua"},
  {name="codespell",           setup="diagnostic.stylua"},
  {name="write-good",          setup="write_good"},
  -- {nil,                   "spell"},
 },
}
return M
