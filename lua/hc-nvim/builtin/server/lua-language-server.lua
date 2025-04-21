---@class lua-language-server.configs
local default_settings={
 addonManager={
  ---@type boolean
  enable=true,
 },
 completion={
  ---@type boolean
  autoRequire=true,
  ---@type "Disable"|"Both"|"Replace"
  callSnippet="Disable",
  ---@type integer
  displayContext=0,
  ---@type boolean
  enable=true,
  ---@type "Disable"|"Both"|"Replace"
  keywordSnippet="Replace",
  ---@type string
  postfix="@",
  ---@type string
  requireSeparator=".",
  ---@type boolean
  showParams=true,
  ---@type "Enable"|"Fallback"|"Disable"
  showWord="Fallback",
  ---@type boolean
  workspaceWord=true,
 },
 diagnostics={
  ---@type lua-language-server.DiagnosticName[]
  disable={},
  ---@type string[]
  disableScheme={"git"},
  ---@type boolean
  enable=true,
  ---@type string[]
  globals={},
  ---@alias lua-language-server.FileStatus
  ---| "Any"
  ---| "Opened"
  ---| "None"
  ---| "Fallback"
  ---@type table<lua-language-server.GroupName, lua-language-server.FileStatus>
  groupFileStatus --[[@enum (key) lua-language-server.GroupName]]={
   -- ambiguity-1
   -- count-down-loop
   -- different-requires
   -- newfield-call
   -- newline-call
   ambiguity="Fallback",
   -- await-in-sync
   -- not-yieldable
   await="Fallback",
   -- codestyle-check
   -- spell-check
   codestyle="Fallback",
   -- duplicate-index
   -- duplicate-set-field
   duplicate="Fallback",
   -- global-in-nil-env
   -- lowercase-global
   -- undefined-env-child
   -- undefined-global
   global="Fallback",
   -- cast-type-mismatch
   -- circle-doc-class
   -- doc-field-no-class
   -- duplicate-doc-alias
   -- duplicate-doc-field
   -- duplicate-doc-param
   -- undefined-doc-class
   -- undefined-doc-name
   -- undefined-doc-param
   -- unknown-cast-variable
   -- unknown-diag-code
   -- unknown-operator
   luadoc="Fallback",
   -- redefined-local
   redefined="Fallback",
   -- close-non-object
   -- deprecated
   -- discard-returns
   strict="Fallback",
   -- no-unknown
   strong="Fallback",
   -- assign-type-mismatch
   -- cast-local-type
   -- cast-type-mismatch
   -- need-check-nillua_ls
   -- param-type-mismatch
   -- return-type-mismatch
   -- undefined-field
   ["type-check"]="Fallback",
   -- missing-parameter
   -- missing-return
   -- missing-return-value
   -- redundant-parameter
   -- redundant-return-value
   -- redundant-value
   -- unbalanced-assignments
   unbalanced="Fallback",
   -- code-after-break
   -- empty-block
   -- redundant-return
   -- trailing-space
   -- unreachable-code
   -- unused-function
   -- unused-label
   -- unused-local
   -- unused-vararg
   unused="Fallback",
  },
  ---@alias lua-language-server.Severity
  ---| "Error"
  ---| "Warning"
  ---| "Information"
  ---| "Hint"
  ---| "Fallback"
  ---@type table<lua-language-server.GroupName, lua-language-server.Severity>
  groupSeverity={
   ambiguity="Fallback",
   await="Fallback",
   codestyle="Fallback",
   duplicate="Fallback",
   global="Fallback",
   luadoc="Fallback",
   redefined="Fallback",
   strict="Fallback",
   strong="Fallback",
   ["type-check"]="Fallback",
   unbalanced="Fallback",
   unused="Fallback",
  },
  ---@type lua-language-server.FileStatus
  ignoredFiles="Opened",
  ---@type lua-language-server.FileStatus
  libraryFiles="Opened",
  ---@type table<lua-language-server.DiagnosticName, lua-language-server.FileStatus>
  neededFileStatus --[[@enum (key) lua-language-server.DiagnosticName]]={
   ["ambiguity-1"]="Any",
   ["assign-type-mismatch"]="Opened",
   ["await-in-sync"]="None",
   ["cast-local-type"]="Opened",
   ["cast-type-mismatch"]="Any",
   ["circle-doc-class"]="Any",
   ["close-non-object"]="Any",
   ["code-after-break"]="Opened",
   ["codestyle-check"]="None",
   ["count-down-loop"]="Any",
   ["deprecated"]="Any",
   ["different-requires"]="Any",
   ["discard-returns"]="Any",
   ["doc-field-no-class"]="Any",
   ["duplicate-doc-alias"]="Any",
   ["duplicate-doc-field"]="Any",
   ["duplicate-doc-param"]="Any",
   ["duplicate-index"]="Any",
   ["duplicate-set-field"]="Any",
   ["empty-block"]="Opened",
   ["global-in-nil-env"]="Any",
   ["lowercase-global"]="Any",
   ["missing-parameter"]="Any",
   ["missing-return"]="Any",
   ["missing-return-value"]="Any",
   ["need-check-nil"]="Opened",
   ["newfield-call"]="Any",
   ["newline-call"]="Any",
   ["no-unknown"]="None",
   ["not-yieldable"]="None",
   ["param-type-mismatch"]="Opened",
   ["redefined-local"]="Opened",
   ["redundant-parameter"]="Any",
   ["redundant-return"]="Opened",
   ["redundant-return-value"]="Any",
   ["redundant-value"]="Any",
   ["return-type-mismatch"]="Opened",
   ["spell-check"]="None",
   ["trailing-space"]="Opened",
   ["unbalanced-assignments"]="Any",
   ["undefined-doc-class"]="Any",
   ["undefined-doc-name"]="Any",
   ["undefined-doc-param"]="Any",
   ["undefined-env-child"]="Any",
   ["undefined-field"]="Opened",
   ["undefined-global"]="Any",
   ["unknown-cast-variable"]="Any",
   ["unknown-diag-code"]="Any",
   ["unknown-operator"]="Any",
   ["unreachable-code"]="Opened",
   ["unused-function"]="Opened",
   ["unused-label"]="Opened",
   ["unused-local"]="Opened",
   ["unused-vararg"]="Opened",
  },
  ---@type table<lua-language-server.DiagnosticName, lua-language-server.Severity>
  severity={
   ["ambiguity-1"]="Warning",
   ["assign-type-mismatch"]="Warning",
   ["await-in-sync"]="Warning",
   ["cast-local-type"]="Warning",
   ["cast-type-mismatch"]="Warning",
   ["circle-doc-class"]="Warning",
   ["close-non-object"]="Warning",
   ["code-after-break"]="Hint",
   ["codestyle-check"]="Warning",
   ["count-down-loop"]="Warning",
   ["deprecated"]="Warning",
   ["different-requires"]="Warning",
   ["discard-returns"]="Warning",
   ["doc-field-no-class"]="Warning",
   ["duplicate-doc-alias"]="Warning",
   ["duplicate-doc-field"]="Warning",
   ["duplicate-doc-param"]="Warning",
   ["duplicate-index"]="Warning",
   ["duplicate-set-field"]="Warning",
   ["empty-block"]="Hint",
   ["global-in-nil-env"]="Warning",
   ["lowercase-global"]="Information",
   ["missing-parameter"]="Warning",
   ["missing-return"]="Warning",
   ["missing-return-value"]="Warning",
   ["need-check-nil"]="Warning",
   ["newfield-call"]="Warning",
   ["newline-call"]="Warning",
   ["no-unknown"]="Warning",
   ["not-yieldable"]="Warning",
   ["param-type-mismatch"]="Warning",
   ["redefined-local"]="Hint",
   ["redundant-parameter"]="Warning",
   ["redundant-return"]="Hint",
   ["redundant-return-value"]="Warning",
   ["redundant-value"]="Warning",
   ["return-type-mismatch"]="Warning",
   ["spell-check"]="Information",
   ["trailing-space"]="Hint",
   ["unbalanced-assignments"]="Warning",
   ["undefined-doc-class"]="Warning",
   ["undefined-doc-name"]="Warning",
   ["undefined-doc-param"]="Warning",
   ["undefined-env-child"]="Information",
   ["undefined-field"]="Warning",
   ["undefined-global"]="Warning",
   ["unknown-cast-variable"]="Warning",
   ["unknown-diag-code"]="Warning",
   ["unknown-operator"]="Warning",
   ["unreachable-code"]="Hint",
   ["unused-function"]="Hint",
   ["unused-label"]="Hint",
   ["unused-local"]="Hint",
   ["unused-vararg"]="Hint",
  },
  ---@type string[]
  unusedLocalExclude={},
  ---@type integer
  workspaceDelay=3000,
  ---@type
  ---| "OnChange"
  ---| "OnSave"
  ---| "None"
  workspaceEvent="OnSave",
  ---@type integer
  workspaceRate=100,
 },
 doc={
  ---@type string[]
  packageName={},
  ---@type string[]
  privateName={},
  ---@type string[]
  protectedName={},
 },
 format={
  defaultConfig={
   ---@type "space"|"tab"
   indent_style="space",
   ---@type number
   indent_size=4,
   ---@type number
   tab_width=4,
   ---@type "none"|"single"|"double"
   quote_style="none",
   ---@type number
   continuation_indent=4,
   ---@type number
   max_line_length=120,
   ---@type "crlf"|"lf"|"cr"|"auto"
   end_of_line="auto",
   ---@type "none"|"comma"|"semicolon"|"only_kv_colon"
   table_separator_style="none",
   ---@type "keep"|"never"|"always"|"smart"
   trailing_table_separator="keep",
   ---@type "keep"|"remove"|"remove_table_only"|"remove_string_only"
   call_arg_parentheses="keep",
   ---@type boolean
   insert_final_newline=true,
   ---@type boolean
   space_around_table_field_list=true,
   ---@type boolean
   space_before_attribute=true,
   ---@type boolean
   space_before_function_open_parenthesis=false,
   ---@type boolean
   space_before_function_call_open_parenthesis=false,
   ---@type boolean
   space_before_closure_open_parenthesis=true,
   ---@type "always"|"only_string"|"only_table"|"none"|boolean
   space_before_function_call_single_arg="always",
   ---@type boolean
   space_around_math_operator=true,
   ---@type boolean
   space_after_comma=true,
   ---@type boolean
   space_after_comma_in_for_statement=true,
   ---@type boolean
   space_around_concat_operator=true,
   ---@type boolean
   space_around_logical_operator=true,
   ---@type boolean
   space_around_assign_operator=true,
   ---@type boolean
   align_call_args=false,
   ---@type boolean
   align_function_params=true,
   ---@type boolean
   align_continuous_assign_statement=true,
   ---@type boolean
   align_continuous_rect_table_field=true,
   ---@type number
   align_continuous_line_space=2,
   ---@type boolean
   align_if_branch=false,
   ---@type "none"|"always"|"contain_curly"
   align_array_table="always",
   ---@type boolean
   align_continuous_similar_call_args=false,
   ---@type boolean
   align_continuous_inline_comment=true,
   ---@type "none"|"always"|"only_call_stmt"
   align_chain_expr="none",
   ---@type boolean
   never_indent_before_if_condition=false,
   ---@type boolean
   never_indent_comment_on_if_branch=false,
   ---@type boolean
   keep_indents_on_empty_lines=false,
   ---@type boolean
   allow_non_indented_comments=false,
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_if_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_do_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_while_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_repeat_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_for_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_local_or_assign_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_function_statement="fixed(2)",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_expression_statement="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_after_comment="keep",
   ---@type "keep"|"fixed(number)"|"min(number)"|"max(number)"|string
   line_space_around_block="fixed(1)",
   ---@type boolean
   break_all_list_when_line_exceed=false,
   ---@type boolean
   auto_collapse_lines=false,
   ---@type boolean
   break_before_braces=false,
   ---@type boolean
   ignore_space_after_colon=false,
   ---@type boolean
   remove_call_expression_list_finish_comma=false,
   ---@type "keep"|"always"|"same_line"|"replace_with_newline"|"never"
   end_statement_with_semicolon="keep",
  },
  ---@type boolean
  enable=true,
 },
 hint={
  ---@type "Enable"|"Auto"|"Disable"
  arrayIndex="Auto",
  ---@type boolean
  await=true,
  ---@type boolean
  enable=false,
  ---@type "All"|"Literal"|"Disable"
  paramName="All",
  ---@type boolean
  paramType=true,
  ---@type "All"|"SameLine"|"Disable"
  semicolon="SameLine",
  ---@type boolean
  setType=false,
 },
 hover={
  ---@type boolean
  enable=true,
  ---@type integer
  enumsLimit=5,
  ---@type boolean
  expandAlias=true,
  ---@type integer
  previewFields=50,
  ---@type boolean
  viewNumber=true,
  ---@type boolean
  viewString=true,
  ---@type integer
  viewStringMax=1000,
 },
 misc={
  ---@type string[]
  parameters={},
  ---@type string
  executablePath="",
 },
 runtime={
  ---@type table<string, "default"|"enable"|"disable">
  builtin={
   basic="default",
   bit="default",
   bit32="default",
   builtin="default",
   coroutine="default",
   debug="default",
   ffi="default",
   io="default",
   jit="default",
   math="default",
   os="default",
   package="default",
   string="default",
   table="default",
   ["table.clear"]="default",
   ["table.new"]="default",
   utf8="default",
  },
  ---@type
  ---| "utf8"
  ---| "ansi"
  ---| "utf16le"
  ---| "utf16be"
  fileEncoding="utf8",
  ---@type string
  meta="${version} ${language} ${encoding}",
  ---@type string[]
  nonstandardSymbol={},
  ---@type string[]
  path={"?.lua","?/init.lua"},
  ---@type boolean
  pathStrict=false,
  ---@type string
  plugin="",
  ---@type string[]
  pluginArgs={},
  ---@type table<string, string>
  special={},
  ---@type boolean
  unicodeName=false,
  ---@type string
  version="Lua 5.4",
 },
 semantic={
  ---@type boolean
  annotation=true,
  ---@type boolean
  enable=true,
  ---@type boolean
  keyword=false,
  ---@type boolean
  variable=true,
 },
 signatureHelp={
  ---@type boolean
  enable=true,
 },
 spell={
  ---@type string[]
  dict={},
 },
 telemetry={
  ---@type boolean|nil
  enable=nil,
 },
 type={
  ---@type boolean
  castNumberToInteger=false,
  ---@type boolean
  weakNilCheck=false,
  ---@type boolean
  weakUnionCheck=false,
 },
 window={
  ---@type boolean
  progressBar=true,
  ---@type boolean
  statusBar=true,
 },
 workspace={
  ---@type
  ---| "Ask" (ask every time)
  ---| "Apply" (always apply automatically)
  ---| "ApplyInMemory" (always apply [definition files](/wiki/definition-files), but don't apply setting)
  ---| "Disable" (Don't ask, don't apply)
  checkThirdParty="Ask",
  ---@type string[]
  ignoreDir={".vscode"},
  ---@type boolean
  ignoreSubmodules=true,
  ---@type string[]
  library={},
  ---@type integer
  maxPreload=5000,
  ---@type integer
  preloadFileSize=500,
  ---@type boolean
  useGitIgnore=true,
  ---@type string[]
  userThirdParty={},
 },
}
---@type table<string,lua-language-server.configs|{}>
local Settings={}
Settings.normal={
 completion={
  enable=true,
  showWord="Disable",
 },
 diagnostics={
  disable={"different-requires"},
  enable=true,
 },
 format={
  defaultConfig={
   indent_style                                ="space",
   indent_size                                 ="1",
   tab_width                                   ="1",
   quote_style                                 ="double",
   call_arg_parentheses                        ="keep",
   continuation_indent                         ="1",
   max_line_length                             ="65535",
   end_of_line                                 ="lf",
   trailing_table_separator                    ="smart",
   detect_end_of_line                          ="true",
   insert_final_newline                        ="false",
   space_around_table_field_list               ="false",
   space_before_attribute                      ="true",
   space_before_function_open_parenthesis      ="false",
   space_before_function_call_open_parenthesis ="false",
   space_before_closure_open_parenthesis       ="false",
   space_before_function_call_single_arg       ="false",
   space_before_open_square_bracket            ="false",
   space_inside_function_call_parentheses      ="false",
   space_inside_function_param_list_parentheses="false",
   space_inside_square_brackets                ="false",
   space_around_table_append_operator          ="false",
   ignore_spaces_inside_function_call          ="false",
   space_before_inline_comment                 ="1",
   space_around_logical_operator               ="false",
   space_around_assign_operator                ="false",
   space_around_math_operator                  ="false",
   space_after_comma                           ="false",
   space_after_comma_in_for_statement          ="false",
   space_around_concat_operator                ="none",
   align_call_args                             ="true",
   align_function_params                       ="true",
   align_continuous_assign_statement           ="true",
   align_continuous_rect_table_field           ="true",
   align_if_branch                             ="true",
   align_array_table                           ="true",
   never_indent_before_if_condition            ="false",
   never_indent_comment_on_if_branch           ="false",
   line_space_after_if_statement               ="fixed(1)",
   line_space_after_do_statement               ="fixed(1)",
   line_space_after_while_statement            ="fixed(1)",
   line_space_after_repeat_statement           ="fixed(1)",
   line_space_after_for_statement              ="fixed(1)",
   line_space_after_local_or_assign_statement  ="fixed(1)",
   line_space_after_expression_statement       ="fixed(1)",
   line_space_after_comment                    ="max(2)",
   line_space_after_function_statement         ="fixed(1)",
   line_space_around_block                     ="fixed(1)",
   break_all_list_when_line_exceed             ="false",
   auto_collapse_lines                         ="false",
   ignore_space_after_colon                    ="false",
   remove_call_expression_list_finish_comma    ="true",
   end_statement_with_semicolon                ="same_line",
   table_separator_style                       ="Comma",
   align_chain_expr                            ="Always",
   align_continuous_similar_call_args          ="true",
   align_continuous_inline_comment             ="true",
   break_before_braces                         ="false",
   keep_indents_on_empty_lines                 ="false",
  },
 },
 codeLens={
  enable=false,
 },
 hint={
  enable=false,
 },
 semantic={
  enable=false,
 },
 runtime={
  pathStrict=true,
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
}
local Util=require("hc-nvim.util")
local Config=require("hc-nvim.config")
Settings.neovim=Util.tbl_extend({},Settings.normal,{
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
  library={
   vim.fs.normalize(vim.fs.joinpath(vim.env.VIMRUNTIME,"lua","vim")),
   "${3rd}/luv/library",
   "${3rd}/busted/library",
  },
 },
})
local function get_config(cwd)
 if Util.is_profile(cwd) then
  return Settings.neovim
 end
 return Settings.normal
end
local M={}
M.cmd={
 -- auto change language
 ("--locale=%s-%s"):format(
  Config.locale.current.language,
  Config.locale.current.country:lower()
 ),
}
M.settings={
 Lua=Settings.normal,
}
M.on_init=function(client)
 local cur_dir=vim.fn.getcwd()
 local last_dir
 local function setconfig()
  cur_dir=vim.fn.getcwd()
  if cur_dir~=last_dir then
   client.config.settings.Lua=get_config(cur_dir)
   last_dir=cur_dir
  end
 end
 vim.api.nvim_create_autocmd("BufRead",{
  callback=setconfig,
 })
 setconfig()
end
return M
