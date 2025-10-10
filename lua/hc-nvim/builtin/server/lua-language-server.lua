---@class Strategy
---@field cond fun(): boolean
---@field func fun(config: table)

---@type Strategy[]
local strategies={}
---@param cond fun(): boolean
---@param func fun(config: table)
local function add_strategy(cond,func)
 table.insert(strategies,{cond=cond,func=func})
end

---@param tbl table
local function apply_strategies(tbl)
 for _,strategy in ipairs(strategies) do
  if strategy.cond() then
   strategy.func(tbl)
  end
 end
end
local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
-- Default
add_strategy(
 function()
  return true
 end,
 function(client)
  Util.tbl_set(client,{"config","settings","Lua"},{
   completion={
    enable=true,
    showWord="Disable",
    workspaceWord=false,
   },
   diagnostics={
    disable={"different-requires"},
    enable=true,
   },
   format={
    defaultConfig={
     indent_style="space",
     indent_size="1",
     tab_width="1",
     quote_style="double",
     call_arg_parentheses="keep",
     continuation_indent="1",
     max_line_length="65535",
     end_of_line="lf",
     trailing_table_separator="smart",
     detect_end_of_line="true",
     insert_final_newline="false",
     space_around_table_field_list="false",
     space_before_attribute="true",
     space_before_function_open_parenthesis="false",
     space_before_function_call_open_parenthesis="false",
     space_before_closure_open_parenthesis="false",
     space_before_function_call_single_arg="false",
     space_before_open_square_bracket="false",
     space_inside_function_call_parentheses="false",
     space_inside_function_param_list_parentheses="false",
     space_inside_square_brackets="false",
     space_around_table_append_operator="false",
     ignore_spaces_inside_function_call="false",
     space_before_inline_comment="1",
     space_around_logical_operator="false",
     space_around_assign_operator="false",
     space_around_math_operator="false",
     space_after_comma="false",
     space_after_comma_in_for_statement="false",
     space_around_concat_operator="none",
     align_call_args="true",
     align_function_params="true",
     align_continuous_assign_statement="true",
     align_continuous_rect_table_field="true",
     align_if_branch="true",
     align_array_table="true",
     never_indent_before_if_condition="false",
     never_indent_comment_on_if_branch="false",
     line_space_after_if_statement="fixed(1)",
     line_space_after_do_statement="fixed(1)",
     line_space_after_while_statement="fixed(1)",
     line_space_after_repeat_statement="fixed(1)",
     line_space_after_for_statement="fixed(1)",
     line_space_after_local_or_assign_statement="fixed(1)",
     line_space_after_expression_statement="fixed(1)",
     line_space_after_comment="max(2)",
     line_space_after_function_statement="fixed(1)",
     line_space_around_block="fixed(1)",
     break_all_list_when_line_exceed="false",
     auto_collapse_lines="false",
     ignore_space_after_colon="false",
     remove_call_expression_list_finish_comma="true",
     end_statement_with_semicolon="same_line",
     table_separator_style="Comma",
     align_chain_expr="Always",
     align_continuous_similar_call_args="true",
     align_continuous_inline_comment="true",
     break_before_braces="false",
     keep_indents_on_empty_lines="false",
    },
   },
   codeLens={
    enable=false,
   },
   hint={
    enable=false,
   },
   semantic={
    enable=true,
    keyword=false,
    variable=true,
    annotation=true,
   },
   runtime={
    pathStrict=true,
   },
   telemetry={
    enable=false,
   },
   window={
    progressBar=false,
    statusBar=false,
   },
   signatureHelp={
    enable=true,
   },
   hover={
    enable=true,
   },
  })
 end
)
-- Neovim
add_strategy(
 function()
  return Util.is_profile(vim.fn.getcwd())
 end,
 function(client)
  Util.tbl_deep_extend(client.config.settings.Lua,{
   runtime={
    version="LuaJIT",
    path={
     "lua/?/init.lua",
     "lua/?.lua",
     "?/init.lua",
     "?.lua",
    },
   },
   workspace={
    checkThirdParty=false,
    maxPreload=2^31,
    preloadFileSize=2^31,
    library={
     vim.env.VIMRUNTIME,
     "${3rd}/luv/library",
     "${3rd}/busted/library",
    },
   },
  })
 end
)
---@type vim.lsp.ClientConfig|{}
local config={}
config.settings={} -- Necessary

config.cmd=vim.list_extend(vim.lsp.config.lua_ls.cmd,{
 ("--locale=%s-%s"):format(
  Config.locale.current.language,
  Config.locale.current.country:lower()
 ),
})
---@param client vim.lsp.Client
local function reattach(client)
 local lsp=vim.lsp
 for buf in pairs(client.attached_buffers) do
  if lsp.buf_is_attached(buf,client.id) then
   lsp.buf_detach_client(buf,client.id)
   lsp.buf_attach_client(buf,client.id)
  end
 end
end

config.on_init=function(client)
 local last_cwd
 local function update_strategy()
  local cur_cwd=vim.fn.getcwd()
  if cur_cwd==last_cwd then
   return
  end
  apply_strategies(client)
  Util.try(function()
            reattach(client)
           end,Util.ERROR)
 end
 vim.api.nvim_create_autocmd({"BufRead","DirChanged"},{
  callback=function()
   update_strategy()
  end,
 })
 update_strategy()
end
return config
