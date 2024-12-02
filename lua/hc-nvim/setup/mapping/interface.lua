local NS=require("hc-nvim.namespace")
---@type mapspec
return {
 {
  override={tags="global"},
  {
   wkspec={"<leader>b",group="Buffer"},
   {name=NS.global_buffer_delete,        lhs="<leader>bd"},
   {name=NS.global_buffer_wipeout,       lhs="<leader>bw"},
   {name=NS.global_buffer_next,          lhs={"<leader>bn","]b"}},
   {name=NS.global_buffer_previous,      lhs={"<leader>bp","[b"}},
   {name=NS.global_buffer_close_left,    lhs="<leader>bl"},
   {name=NS.global_buffer_close_right,   lhs="<leader>br"},
   {name=NS.global_buffer_close_other,   lhs="<leader>bc"},
   {name=NS.global_buffer_selecte_delete,lhs="<leader>bG"},
   {name=NS.global_buffer_selecte_goto,  lhs="<leader>bg"},
  },
  {
   wkspec={"<leader><tab>",group="Tab"},
   {name=NS.global_tab_new,     lhs="<leader><tab>n"},
   {name=NS.global_tab_close,   lhs="<leader><tab>c"},
   {name=NS.global_tab_previous,lhs="[<tab>"},
   {name=NS.global_tab_first,   lhs="[<c-tab>"},
   {name=NS.global_tab_next,    lhs="]<tab>"},
   {name=NS.global_tab_last,    lhs="]<c-tab>"},
  },
  {
   {name=NS.global_window_left, lhs="<c-h>"},
   {name=NS.global_window_down, lhs="<c-j>"},
   {name=NS.global_window_up,   lhs="<c-k>"},
   {name=NS.global_window_right,lhs="<c-l>"},
  },
  {
   wkspec={"<leader>o",group="Options"},
   {name=NS.global_option_wrap,          lhs="<leader>ow"},
   {name=NS.global_option_cursorline,    lhs="<leader>ocl"},
   {name=NS.global_option_cursorcolumn,  lhs="<leader>occ"},
   {name=NS.global_option_signcolum,     lhs="<leader>os"},
   {name=NS.global_option_number,        lhs="<leader>on"},
   {name=NS.global_option_relativenumber,lhs="<leader>oN"},
   {name=NS.global_option_foldenable,    lhs="<leader>oz"},
   {name=NS.global_option_syntax,        lhs="<leader>oh"},
   {name=NS.global_option_treesitter,    lhs="<leader>ot"},
  },
  {
   {name=NS.global_cmd_nohlsearch,      lhs="<esc>"},
   {name=NS.global_cmd_write,           lhs="<c-s>"},
   {name=NS.global_escape_terminal,     lhs="<esc>",      mode="t"},
   {name=NS.global_auto_escape_terminal,lhs="<bs>",       mode="t"},
   {name=NS.global_delete_right,        lhs="<c-l>",      mode="i"},
   {name=NS.global_normal_q,            lhs="ge"},
   {name=NS.global_normal_Q,            lhs="gE"},
   {name=NS.global_edit_break_points,   lhs={",",".",";"},mode="i"},
   {name=NS.global_visual_indent,       lhs={"<",">"},    mode="x"},
  },
  {
   override={mode={"n","x","o"}},
   {name=NS.global_change_c,lhs="c"},
   {name=NS.global_change_r,lhs="b"},
   {name=NS.global_change_R,lhs="B"},
  },
  {
   override={mode={"n","x","o"}},
   {name=NS.global_motion_ge,    lhs="q"},
   {name=NS.global_motion_gE,    lhs="Q"},
   {name=NS.global_motion_b,     lhs="w"},
   {name=NS.global_motion_B,     lhs="W"},
   {name=NS.global_motion_e,     lhs="e"},
   {name=NS.global_motion_E,     lhs="E"},
   {name=NS.global_motion_w,     lhs="r"},
   {name=NS.global_motion_W,     lhs="R"},
   {name=NS.global_motion_0,     lhs="0"},
   {name=NS.global_motion_doller,lhs="$"},
   {name=NS.global_motion_caret, lhs="^"},
   {name=NS.global_motion_g_,    lhs="g_"},
   {name=NS.global_motion_V,     lhs="V"},
   {name=NS.global_motion_j,     lhs="j"},
   {name=NS.global_motion_k,     lhs="k"},
   {name=NS.global_motion_h,     lhs="h"},
   {name=NS.global_motion_l,     lhs="l"},
  },
 },{
 wkspec={"<leader>l",group="Lsp"},
 override={tags={"lsp"}},
 {name=NS.lsp_codeAction,             lhs={"<leader>lc","<leader>c"}},
 {name=NS.lsp_declaration,            lhs="gy"},
 {name=NS.lsp_definition,             lhs="gl"},
 {name=NS.lsp_diagnostic_next,        lhs="]D",                     mode={"n","x","o"}},
 {name=NS.lsp_diagnostic_previous,    lhs="[D",                     mode={"n","x","o"}},
 {name=NS.lsp_diagnostic_toggle,      lhs="<leader>od"},
 {name=NS.lsp_document_symbols,       lhs="<leader>ls"},
 {name=NS.lsp_formatting,             lhs={"<leader>lf","<F3>"},    mode={"n","x"}},
 {name=NS.lsp_hover,                  lhs={"K","<leader>lh"}},
 {name=NS.lsp_implementation,         lhs="gY"},
 {name=NS.lsp_incoming_calls,         lhs="<leader>li"},
 {name=NS.lsp_outgoing_calls,         lhs="<leader>lo"},
 {name=NS.lsp_references,             lhs="gz"},
 {name=NS.lsp_rename,                 lhs={"<F2>","gZ"}},
 {name=NS.lsp_signatureHelp,          lhs={"gK","<leader>lj"}},
 {name=NS.lsp_typeDefinition,         lhs="gL"},
 {name=NS.lsp_workspace_add_folder,   lhs="<leader>la"},
 {name=NS.lsp_workspace_list_folders, lhs="<leader>ll"},
 {name=NS.lsp_workspace_remove_folder,lhs="<leader>lr"},
 {name=NS.lsp_workspace_symbols,      lhs="<leader>lS"},
},{
 override={tags="nvim-lspconfig"},
 {name=NS.nvim_lspconfig_lspinfo,lhs="<leader>lI",desc="Lspinfo"},
},{
 override={tags="yanky"},
 {name=NS.yanky_put_after,                    lhs="p",   mode={"n","x"}},
 {name=NS.yanky_put_before,                   lhs="P",   mode={"n","x"}},
 {name=NS.yanky_g_put_after,                  lhs="gp",  mode={"n","x"}},
 {name=NS.yanky_g_put_before,                 lhs="gP",  mode={"n","x"}},
 {name=NS.yanky_previous_entry,               lhs="<c-p>"},
 {name=NS.yanky_next_entry,                   lhs="<c-n>"},
 {name=NS.yanky_put_indent_after_linewise,    lhs="]p"},
 {name=NS.yanky_put_indent_before_linewise,   lhs="[p"},
 {name=NS.yanky_put_indent_after_shift_right, lhs=">p"},
 {name=NS.yanky_put_indent_after_shift_left,  lhs="<p"},
 {name=NS.yanky_put_indent_before_shift_left, lhs="<P"},
 {name=NS.yanky_put_indent_before_shift_right,lhs=">P"},
 {name=NS.yanky_put_after_filter,             lhs="=p"},
 {name=NS.yanky_put_before_filter,            lhs="=P"},
},{
 override={tags="nvim-spider"},
 {name=NS.global_motion_ge},
 {name=NS.global_motion_b},
 {name=NS.global_motion_e},
 {name=NS.global_motion_w},
},{
 override={tags="which-key"},
 {name=NS.which_key_window_mode,lhs="<leader><c-w>"},
},{
 override={tags="nvim-cmp"},
 {
  override={mode={"c","s","i"},fallback=true},
  {name=NS.cmp_select_prev,lhs="<c-p>"},
  {name=NS.cmp_select_next,lhs="<c-n>"},
  {name=NS.cmp_abort,      lhs="<c-e>"},
  {name=NS.cmp_confirm,    lhs="<c-y>"},
 },
 {
  override={mode={"s","i"},fallback=true},
  {name=NS.cmp_toggle_doc,lhs="<c-z>"},
  {name=NS.cmp_doc_up,    lhs="<c-b>"},
  {name=NS.cmp_doc_down,  lhs="<c-f>"},
 },
 {name=NS.cmp_toggle,lhs="<leader>ocp"},
},
 {
  override={tags="LuaSnip"},
  {name=NS.luasnip_expand,lhs="<c-,>",mode="i"},
  {
   override={mode={"s","i"}},
   {name=NS.luasnip_jump_prev,    lhs="<c-;>"},
   {name=NS.luasnip_jump_next,    lhs="<c-'>"},
   {name=NS.luasnip_change_choice,lhs="<c-/>"},
  },
 },{
 override={tags={"lsp","symbol-usage"}},
 {name=NS.symbol_usage_toggle,lhs="<leader>ou"},
},{
 wkspec={"<leader>a",group="AI"},
 override={tags="fittencode"},
 {
  override={mode="i"},
  {name=NS.fittencode_accept_all_suggestions,lhs="<c-g>a"},
  {name=NS.fittencode_accept_word,           lhs="<c-g>w"},
  {name=NS.fittencode_accept_line,           lhs="<c-g>l"},
  {name=NS.fittencode_triggering_completion, lhs="<c-g>A"},
  {name=NS.fittencode_revoke_word,           lhs="<c-g>W"},
  {name=NS.fittencode_revoke_line,           lhs="<c-g>L"},
 },
 {
  override={mode={"n","x"}},
  {name=NS.fittencode_api_panel,lhs="<leader>A"},
 },
},{
 override={tags="nvim-various-textobjs"},
 {
  override={
   mode={"o","x"},
  },
  {name=NS.various_tonextclosingbracket,        lhs="<leader>b"},
  {name=NS.various_tonextquotationmark,         lhs="<leader>q"},
  {name=NS.various_restofparagraph,             lhs="<leader>p"},
  {name=NS.various_entirebuffer,                lhs="gG"},
  {name=NS.various_neareol,                     lhs="<leader>_"},
  {name=NS.various_column,                      lhs="<leader>c"},
  {name=NS.various_lastchange,                  lhs="<leader>u"},
  {name=NS.various_url,                         lhs="<leader>l"},
  {name=NS.various_diagnostic,                  lhs="<leader>x"},
  {name=NS.various_visibleinwindow,             lhs="<leader>w"},
  {name=NS.various_restofwindow,                lhs="<leader>W"},
  {name=NS.various_restofindentation,           lhs="<leader>i"},
  {name=NS.various_indentation_inner_inner,     lhs="<leader>ii"},
  {name=NS.various_indentation_outer_inner,     lhs="<leader>ai"},
  {name=NS.various_indentation_inner_outer,     lhs="<leader>iI"},
  {name=NS.various_indentation_outer_outer,     lhs="<leader>aI"},
  {name=NS.various_greedyouterindentation_inner,lhs="<leader>gi"},
  {name=NS.various_greedyouterindentation_outer,lhs="<leader>gI"},
  {name=NS.various_subword_inner,               lhs="<leader>iS"},
  {name=NS.various_subword_outer,               lhs="<leader>aS"},
  {name=NS.various_anyquote_inner,              lhs="<leader>iq"},
  {name=NS.various_anyquote_outer,              lhs="<leader>aq"},
  {name=NS.various_anybracket_inner,            lhs="<leader>ib"},
  {name=NS.various_anybracket_outer,            lhs="<leader>ab"},
  {name=NS.various_linecharacterwise_inner,     lhs="<leader>iL"},
  {name=NS.various_linecharacterwise_outer,     lhs="<leader>aL"},
  {name=NS.various_notebookcell_inner,          lhs="<leader>in"},
  {name=NS.various_notebookcell_outer,          lhs="<leader>an"},
  {name=NS.various_value_inner,                 lhs="<leader>iv"},
  {name=NS.various_value_outer,                 lhs="<leader>av"},
  {name=NS.various_key_inner,                   lhs="<leader>ik"},
  {name=NS.various_key_outer,                   lhs="<leader>ak"},
  {name=NS.various_number_inner,                lhs="<leader>ix"},
  {name=NS.various_number_outer,                lhs="<leader>ax"},
  {name=NS.various_closedfold_inner,            lhs="<leader>iZ"},
  {name=NS.various_closedfold_outer,            lhs="<leader>aZ"},
  {name=NS.various_chainmember_inner,           lhs="<leader>ic"},
  {name=NS.various_chainmember_outer,           lhs="<leader>ac"},
 },
},{
 wkspec={"<leader>f",group="Flash"},
 override={tags="flash"},
 {
  override={mode={"n","x","o"}},
  {index="modes.char.keys.f",value="f",lazykeys=true},
  {index="modes.char.keys.F",value="F",lazykeys=true},
  {index="modes.char.keys.t",value="t",lazykeys=true},
  {index="modes.char.keys.T",value="T",lazykeys=true},
  {index="modes.char.keys.;",value=";",lazykeys=true},
  {index="modes.char.keys.,",value=",",lazykeys=true},
  {
   override={prefix="<leader>f"},
   {name=NS.flash_jump,                   lhs="s"},
   {name=NS.flash_jump_h,                 lhs="h"},
   {name=NS.flash_jump_j,                 lhs="j"},
   {name=NS.flash_jump_k,                 lhs="k"},
   {name=NS.flash_jump_l,                 lhs="l"},
   {name=NS.flash_jump_e,                 lhs="e"},
   {name=NS.flash_jump_ge,                lhs="w"},
   {name=NS.flash_jump_cword,             lhs="c"},
   {name=NS.flash_jump_line,              lhs={"u","0"}},
   {name=NS.flash_jump_line_non_blank,    lhs={"i","^"}},
   {name=NS.flash_jump_line_end_non_blank,lhs={"o","("}},
   {name=NS.flash_jump_line_end,          lhs={"p","$"}},
   {name=NS.flash_treesitter_jump,        lhs="d"},
   {name=NS.flash_treesitter_search,      lhs="f"},
   {name=NS.flash_treesitter_start,       lhs="F"},
   {name=NS.flash_remote,                 lhs="r",     mode="o"},
   {name=NS.flash_remote_line,            lhs="R",     mode="o"},
   {name=NS.flash_jump_cword_range,       lhs="v",     mode="n"},
   {name=NS.flash_jump_selection,         lhs="v",     mode="x"},
  },
 },
 {name=NS.flash_toggle,lhs="<c-s>",mode="c"},
},{
 override={tags="rainbow-delimiters"},
 {name=NS.rainbow_delimiters_toggle,lhs="<leader>or"},
},{
 override={tags="marks"},
 {name=NS.marks_set,          lhs="ms"},
 {name=NS.marks_set_next,     lhs="mn"},
 {name=NS.marks_toggle,       lhs="mm"},
 {name=NS.marks_next,         lhs={"mn","m]"}},
 {name=NS.marks_prev,         lhs={"mN","m["}},
 {name=NS.marks_preview,      lhs="mp"},
 {name=NS.marks_next_bookmark,lhs="m}"},
 {name=NS.marks_prev_bookmark,lhs="m{"},
 {name=NS.marks_delete,       lhs="md"},
 {name=NS.marks_delete_line,  lhs="ml"},
 {name=NS.marks_delete_buf,   lhs="mb"},
 {name=NS.marks_annotate,     lhs="ma"},
 {name=NS.marks_toggle_signs, lhs="mt"},
},{
 wkspec={"<leader>r",group="Spectre"},
 override={tags="nvim-spectre"},
 {name=NS.nvim_spectre_toggle,          lhs="<leader>rr"},
 {name=NS.nvim_spectre_open_file_search,lhs="<leader>rf"},
 {name=NS.nvim_spectre_current_word,    lhs="<leader>rw"},
 {name=NS.nvim_spectre_open_visual,     lhs="<leader>r",mode="x"},
 {
  override={lazykey=false},
  {index="mapping.toggle_line.map",         value="<leader>rl"},
  {index="mapping.enter_file.map",          value="<cr>"},
  {index="mapping.send_to_qf.map",          value="<leader>rq"},
  {index="mapping.replace_cmd.map",         value="<leader>rc"},
  {index="mapping.show_option_menu.map",    value="<leader>ro"},
  {index="mapping.run_current_replace.map", value="<leader>rc"},
  {index="mapping.run_replace.map",         value="<leader>ra"},
  {index="mapping.change_view_mode.map",    value="<leader>rv"},
  {index="mapping.change_replace_sed.map",  value="<leader>rs"},
  {index="mapping.change_replace_oxi.map",  value="<leader>ro"},
  {index="mapping.toggle_live_update.map",  value="<leader>ru"},
  {index="mapping.toggle_ignore_case.map",  value="<leader>ri"},
  {index="mapping.toggle_ignore_hidden.map",value="<leader>rh"},
  {index="mapping.resume_last_search.map",  value="<leader>rl"},
 },
},{
 override={tags="Comment"},
 {index="opleader.line", value="gb", desc="Comment toggle linewise (visual)", mode="x"},
 {index="opleader.line", value="gb", desc="Comment toggle linewise"},
 {index="opleader.block",value="gb", desc="Comment toggle blockwise (visual)",mode="x"},
 {index="opleader.block",value="gb", desc="Comment toggle blockwise"},
 {index="toggler.line",  value="gcc",desc="Comment toggle current line"},
 {index="toggler.block", value="gbb",desc="Comment toggle current block"},
 {index="extra.above",   value="gcO",desc="Comment insert above"},
 {index="extra.below",   value="gco",desc="Comment insert below"},
 {index="extra.eol",     value="gcA",desc="Comment insert end of line"},
},{
 override={tags="tabout"},
 {index="tabkey",          value="<c-s>",desc="Tabout",         mode="i"},
 {index="backwards_tabkey",value="<c-b>",desc="Tabout backward",mode="i"},
},{
 wkspec={"<leader>g",group="Git"},
 override={tags="gitsigns"},
 {name=NS.gitsigns_next_hunk,                lhs="]h"},
 {name=NS.gitsigns_prev_hunk,                lhs="[h"},
 {name=NS.gitsigns_reset_hunk,               lhs="<leader>gr"},
 {name=NS.gitsigns_preview_hunk,             lhs="<leader>gp"},
 {name=NS.gitsigns_blame_line,               lhs="<leader>gb"},
 {name=NS.gitsigns_toggle_deleted,           lhs="<leader>gtd"},
 {name=NS.gitsigns_toggle_current_line_blame,lhs="<leader>gtb"},
 {name=NS.gitsigns_toggle_linehl,            lhs="<leader>gtl"},
 {name=NS.gitsigns_toggle_numhl,             lhs="<leader>gtn"},
 {name=NS.gitsigns_toggle_signs,             lhs="<leader>gts"},
},{
 override={tags="neogit"},
 {name=NS.open_neogit,lhs="<leader>gg"},
},{
 override={tags="window-mode"},
 {name=NS.window_mode_enter,lhs="<leader><c-w>"},
},{
 override={tags="hc-substitute"},
 {name=NS.hc_substitute_paste_eol,        lhs="sm"},
 {name=NS.hc_substitute_paste_line,       lhs="sd"},
 {name=NS.hc_substitute_paste_op,         lhs="sp"},
 {name=NS.hc_substitute_exchange_cancel,  lhs="sc"},
 {name=NS.hc_substitute_exchange_line,    lhs="sl"},
 {name=NS.hc_substitute_exchange_op,      lhs="sx"},
 {name=NS.hc_substitute_paste_visual,     lhs="P",mode="x"},
 {name=NS.hc_substitute_exchange_visual,  lhs="X",mode="x"},
 {name=NS.hc_substitute_substitute_op,    lhs="ss"},
 {name=NS.hc_substitute_substitute_visual,lhs="S",mode="x"},
},{
 wkspec={"<leader>n",group="Noice"},
 override={tags="noice"},
 {name=NS.noice_history,  lhs="<leader>nn"},
 {name=NS.noice_last,     lhs="<leader>nl"},
 {name=NS.noice_dismiss,  lhs="<leader>nm"},
 {name=NS.noice_errors,   lhs="<leader>ne"},
 {name=NS.noice_stats,    lhs="<leader>ns"},
 {name=NS.noice_telescope,lhs="<leader>nt"},
 {name=NS.noice_disable,  lhs="<leader>nd"},
 {name=NS.noice_enable,   lhs="<leader>na"},
 {name=NS.noice_redirect, lhs="<c-cr>",   mode="c"},
 {
  override={mode={"n","i","s"},fallback=true},
  {name=NS.noice_scroll_up,  lhs="<c-f>"},
  {name=NS.noice_scroll_down,lhs="<c-b>"},
 },
},{
 override={tags="numb"},
 {name=NS.numb_toggle,mode="n",lhs="<leader>op"},
},{
 override={tags="wildfire"},
 {index="keymaps.init_selection",  value="<s-cr>"},
 {index="keymaps.node_incremental",value="<cr>", lazykey=false},
 {index="keymaps.node_decremental",value="<esc>",lazykey=false},
},{
 override={tags="nvim-treesitter"},
 {
  override={prefix="incremental_selection.keymaps."},
  {index="init_selection",   value="<s-cr>"},
  {index="node_incremental", value="<cr>",        lazykey=false},
  {index="node_decremental", value="<s-cr>",      lazykey=false},
  {index="scope_incremental",value="<leader><cr>",lazykey=false},
 },
},{
 override={tags="nvim-treesitter-textobjects"},
 {
  override={
   prefix="textobjects.select.keymaps.",
   key_as_lhs=true,
   mode={"x","o"},
  },
  {
   {index="ig",desc="Assignment lhs",value={desc="Assignment lhs",query="@assignment.lhs"}},
   {index="ih",desc="Assignment rhs",value={desc="Assignment rhs",query="@assignment.rhs"}},
   {index="in",desc="Number",        value={desc="Number",query="@number.inner"}},
   {index="aS",desc="Statement",     value={desc="Statement",query="@statement.outer"}},
   {index="iC",desc="Class",         value={desc="Class",query="@class.inner"}},
   {index="aC",desc="Class",         value={desc="Class",query="@class.outer"}},
   {index="iF",desc="Frame",         value={desc="Frame",query="@frame.inner"}},
   {index="aF",desc="Frame",         value={desc="Frame",query="@frame.outer"}},
   {index="iR",desc="Regex",         value={desc="Regex",query="@regex.inner"}},
   {index="aR",desc="Regex",         value={desc="Regex",query="@regex.outer"}},
   {index="aa",desc="Call",          value={desc="Call",query="@call.outer"}},
   {index="ab",desc="Block",         value={desc="Block",query="@block.outer"}},
   {index="ac",desc="Comment",       value={desc="Comment",query="@comment.outer"}},
   {index="af",desc="Function",      value={desc="Function",query="@function.outer"}},
   {index="ai",desc="Assignment",    value={desc="Assignment",query="@assignment.outer"}},
   {index="al",desc="Loop",          value={desc="Loop",query="@loop.inner"}},
   {index="al",desc="Loop",          value={desc="Loop",query="@loop.outer"}},
   {index="io",desc="Conditional",   value={desc="Conditional",query="@conditional.inner"}},
   {index="ao",desc="Conditional",   value={desc="Conditional",query="@conditional.outer"}},
   {index="iP",desc="Parameter",     value={desc="Parameter",query="@parameter.inner"}},
   {index="aP",desc="Parameter",     value={desc="Parameter",query="@parameter.outer"}},
   {index="ir",desc="Return",        value={desc="Return",query="@return.inner"}},
   {index="ar",desc="Return",        value={desc="Return",query="@return.outer"}},
   {index="at",desc="Attribute",     value={desc="Attribute",query="@attribute.outer"}},
   {index="ia",desc="Call",          value={desc="Call",query="@call.inner"}},
   {index="ib",desc="Block",         value={desc="Block",query="@block.inner"}},
   {index="ic",desc="Comment",       value={desc="Comment",query="@comment.inner"}},
   {index="if",desc="Function",      value={desc="Function",query="@function.inner"}},
   {index="ii",desc="Assignment",    value={desc="Assignment",query="@assignment.inner"}},
   {index="it",desc="Attribute",     value={desc="Attribute",query="@attribute.inner"}},
  },
 },
 {
  override={
   prefix="textobjects.move.goto_next_start.",
   key_as_lhs=true,
   mode={"n","x","o"},
  },
  {index="]f",desc="Next function", value={desc="Next function",query="@function.outer"}},
  {index="]F",desc="Next class",    value={desc="Next class",query="@class.outer"}},
  {index="]S",desc="Next scope",    value={desc="Next scope",query="@local.scope",query_group="locals"}},
  {index="]P",desc="Next parameter",value={desc="Next parameter",query="@parameter.outer"}},
  {index="]c",desc="Next comment",  value={desc="Next comment",query="@comment.outer"}},
  {index="]C",desc="Next condition",value={desc="Next condition",query="@conditional.outer"}},
  {index="]z",desc="Next fold",     value={desc="Next fold",query="@fold",query_group="folds"}},
 },
 {
  override={
   prefix="textobjects.move.goto_previous_start.",
   key_as_lhs=true,
   mode={"n","x","o"},
  },
  {index="[f",desc="Prev function", value={desc="Prev function",query="@function.outer"}},
  {index="[F",desc="Prev class",    value={desc="Prev class",query="@class.outer"}},
  {index="[S",desc="Prev scope",    value={desc="Prev scope",query="@scope",query_group="locals"}},
  {index="[P",desc="Prev parameter",value={desc="Prev parameter",query="@parameter.outer"}},
  {index="[c",desc="Prev comment",  value={desc="Prev comment",query="@comment.outer"}},
  {index="[C",desc="Prev condition",value={desc="Prev condition",query="@conditional.outer"}},
  {index="[z",desc="Prev fold",     value={desc="Prev fold",query="@fold",query_group="folds"}},
 },
},{
 override={tags="treesj"},
 {name=NS.tsj_join,  lhs="<leader>j"},
 {name=NS.tsj_split, lhs="<leader>k"},
 {name=NS.tsj_toggle,lhs="<leader>K"},
},{
 override={tags="nvim-treesitter-context"},
 {name=NS.goto_treesitter_context,lhs="[["},
},{
 override={tags="indent-blankline"},
 {name=NS.ibl_toggle,lhs="<leader>oI"},
},{
 override={tags="nvim-ufo"},
 {name=NS.ufo_open_all_folds,        lhs="zR"},
 {name=NS.ufo_open_folds,            lhs="zr"},
 {name=NS.ufo_close_all_folds,       lhs="zM"},
 {name=NS.ufo_peek_fold_under_cursor,lhs="zk"},
 {name=NS.ufo_goto_previous_fold,    lhs="[z"},
 {name=NS.ufo_goto_next_fold,        lhs="]z"},
 {name=NS.ufo_close_fold_to_depth,   lhs="zp"},
},{
 wkspec={"<leader>P",group="Window Picker"},
 override={tags="nvim-window-picker"},
 {name=NS.nvim_window_picker_goto_window,     lhs="<leader>Pa"},
 {name=NS.nvim_window_picker_swap_window,     lhs="<leader>Ps"},
 {name=NS.nvim_window_picker_swap_window_with,lhs="<leader>Pd"},
},{
 wkspec={"<leader>D",group="Todo Comments"},
 override={tags="todo-comments"},
 {name=NS.todo_comments_location_list,lhs="<leader>Dl"},
 {name=NS.todo_comments_quick_fix,    lhs="<leader>Dq"},
 {name=NS.todo_comments_trouble,      lhs="<leader>Dx"},
 {name=NS.todo_comments_telescope,    lhs="<leader>Dt"},
 {name=NS.todo_comments_prev,         lhs="[e"},
 {name=NS.todo_comments_next,         lhs="]e"},
},{
 override={tags="binary-swap"},
 {name=NS.swap_operand,              lhs="<leader>sz"},
 {name=NS.swap_operand_with_operator,lhs="<leader>sx"},
},{
 wkspec={"<leader>s",group="Swap"},
 override={tags="iswap"},
 {name=NS.iswap,                lhs="<leader>sw"},
 {name=NS.iswap_with,           lhs="<leader>se"},
 {name=NS.iswap_with_left,      lhs="<leader>sq"},
 {name=NS.iswap_with_right,     lhs="<leader>sr"},
 {name=NS.iswap_node,           lhs="<leader>ss"},
 {name=NS.iswap_node_with,      lhs="<leader>sd"},
 {name=NS.iswap_node_with_left, lhs="<leader>sa"},
 {name=NS.iswap_node_with_right,lhs="<leader>sf"},
 {name=NS.imove,                lhs="<leader>su"},
 {name=NS.imove_with,           lhs="<leader>si"},
 {name=NS.imove_with_left,      lhs="<leader>sy"},
 {name=NS.imove_with_right,     lhs="<leader>so"},
 {name=NS.imove_node,           lhs="<leader>sj"},
 {name=NS.imove_node_with,      lhs="<leader>sk"},
 {name=NS.imove_node_with_left, lhs="<leader>sh"},
 {name=NS.imove_node_with_right,lhs="<leader>sl"},
},{
 wkspec={"<leader>e",group="Neotree"},
 override={tags="neo-tree"},
 {name=NS.neotree_action_close,          lhs="<leader>ec"},
 {name=NS.neotree_action_focus,          lhs="<leader>ef"},
 {name=NS.neotree_action_show,           lhs="<leader>es"},
 {name=NS.neotree_filesystem_current_dir,lhs="<leader>ec"},
 {name=NS.neotree_filesystem_vim_cwd,    lhs="<leader>ew"},
 {name=NS.neotree_filesystem_env_pwd,    lhs="<leader>ep"},
 {name=NS.neotree_filesystem_root,       lhs="<leader>e/"},
 {name=NS.neotree_reveal,                lhs="<leader>er"},
 {name=NS.neotree_show_buffers,          lhs="<leader>eb"},
 {name=NS.neotree_show_filesystem,       lhs="<leader>eF"},
 {name=NS.neotree_show_git,              lhs="<leader>eg"},
 {name=NS.neotree_toggle,                lhs="<leader><leader>"},
},{
 override={tags="zen-mode"},
 {name=NS.zen_mode_toggle,lhs="<leader>Z"},
},{
 wkspec={"<leader>T",group="Toggleterm"},
 override={tags="toggleterm"},
 {
  override={mode={"n","t"}},
  {name=NS.toggleterm_horizontal,lhs="<M-i>"},
  {name=NS.toggleterm_vertical,  lhs="<M-v>"},
  {name=NS.toggleterm_float,     lhs="<M-f>"},
  {name=NS.toggleterm_tab,       lhs="<M-t>"},
 },
 {name=NS.toggleterm_sendline,lhs="<leader>Ts",mode={"n","x"}},
 {name=NS.toggleterm_file_dir,lhs="<leader>Tc"},
 {name=NS.toggleterm_cwd,     lhs="<leader>Tw"},
},{
 wkspec={"<leader>v",group="Multicursors"},
 override={tags="multicursors"},
 {name=NS.multicursors_word,           lhs="<leader>vm"},
 {name=NS.multicursors_undercursor,    lhs="<leader>vc"},
 {name=NS.multicursors_pattern,        lhs="<leader>vp"},
 {name=NS.multicursors_visualselection,lhs="<leader>vm",mode="x"},
 {name=NS.multicursors_visualpattern,  lhs="<leader>vp",mode="x"},
},{
 wkspec={"<leader>t",group="Telescope"},
 override={tags="telescope"},
 {name=NS.telescope_builtin_autocommands,                 lhs="<leader>ta"},
 {name=NS.telescope_builtin_buffers,                      lhs="<leader>tb"},
 {name=NS.telescope_builtin_builtin,                      lhs="<leader>tB"},
 {name=NS.telescope_builtin_colorscheme,                  lhs="<leader>tC"},
 {name=NS.telescope_builtin_command_history,              lhs="<leader>tq"},
 {name=NS.telescope_builtin_commands,                     lhs="<leader>t:"},
 {name=NS.telescope_builtin_current_buffer_fuzzy_find,    lhs="<leader>t/"},
 {name=NS.telescope_builtin_current_buffer_tags,          lhs="<leader>tt"},
 {name=NS.telescope_builtin_diagnostics,                  lhs="<leader>td"},
 {name=NS.telescope_builtin_filetypes,                    lhs="<leader>tt"},
 {name=NS.telescope_builtin_find_files,                   lhs="<leader>tf"},
 {name=NS.telescope_builtin_git_bcommits,                 lhs="<leader>tgc"},
 {name=NS.telescope_builtin_git_bcommits_range,           lhs="<leader>tgr"},
 {name=NS.telescope_builtin_git_branches,                 lhs="<leader>tgb"},
 {name=NS.telescope_builtin_git_commits,                  lhs="<leader>tgc"},
 {name=NS.telescope_builtin_git_files,                    lhs="<leader>tgf"},
 {name=NS.telescope_builtin_git_stash,                    lhs="<leader>tgh"},
 {name=NS.telescope_builtin_git_status,                   lhs="<leader>tgs"},
 {name=NS.telescope_builtin_grep_string,                  lhs="<leader>tv"},
 {name=NS.telescope_builtin_help_tags,                    lhs="<leader>th"},
 {name=NS.telescope_builtin_highlights,                   lhs="<leader>tH"},
 {name=NS.telescope_builtin_jumplist,                     lhs="<leader>tj"},
 {name=NS.telescope_builtin_keymaps,                      lhs="<leader>tK"},
 {name=NS.telescope_builtin_live_grep,                    lhs="<leader>tF"},
 {name=NS.telescope_builtin_loclist,                      lhs="<leader>tc"},
 {name=NS.telescope_builtin_lsp_definitions,              lhs="<leader>tl"},
 {name=NS.telescope_builtin_lsp_type_definitions,         lhs="<leader>tL"},
 {name=NS.telescope_builtin_lsp_implementations,          lhs="<leader>tI"},
 {name=NS.telescope_builtin_lsp_references,               lhs="<leader>tz"},
 {name=NS.telescope_builtin_lsp_incoming_calls,           lhs="<leader>toi"},
 {name=NS.telescope_builtin_lsp_outgoing_calls,           lhs="<leader>toa"},
 {name=NS.telescope_builtin_lsp_document_symbols,         lhs="<leader>ts"},
 {name=NS.telescope_builtin_lsp_workspace_symbols,        lhs="<leader>tw"},
 {name=NS.telescope_builtin_lsp_workspace_dynamic_symbols,lhs="<leader>tW"},
 {name=NS.telescope_builtin_man_pages,                    lhs="<leader>tM"},
 {name=NS.telescope_builtin_marks,                        lhs="<leader>tm"},
 {name=NS.telescope_builtin_oldfiles,                     lhs="<leader>tO"},
 {name=NS.telescope_builtin_pickers,                      lhs="<leader>tp"},
 {name=NS.telescope_builtin_planets,                      lhs="<leader>tP"},
 {name=NS.telescope_builtin_quickfix,                     lhs="<leader>tq"},
 {name=NS.telescope_builtin_quickfixhistory,              lhs="<leader>tQ"},
 {name=NS.telescope_builtin_registers,                    lhs="<leader>t@"},
 {name=NS.telescope_builtin_reloader,                     lhs="<leader>tR"},
 {name=NS.telescope_builtin_resume,                       lhs="<leader>tr"},
 {name=NS.telescope_builtin_search_history,               lhs="<leader>t?"},
 {name=NS.telescope_builtin_spell_suggest,                lhs="<leader>t="},
 {name=NS.telescope_builtin_symbols,                      lhs="<leader>tS"},
 {name=NS.telescope_builtin_tags,                         lhs="<leader>t'"},
 {name=NS.telescope_builtin_tagstack,                     lhs="<leader>t\""},
 {name=NS.telescope_builtin_treesitter,                   lhs="<leader>tT"},
 {name=NS.telescope_builtin_vim_options,                  lhs="<leader>to"},
},{
 override={
  tags="mini-align",
  mode={"n","x"},
 },
 {index="mappings.start",             value="<leader>ma",desc="Align"},
 {index="mappings.start_with_preview",value="<leader>mA",desc="Align with preview"},
},(function()
 local op={
  evaluate="<leader>mv",
  multiply="<leader>mm",
  exchange="<leader>mx",
  replace ="<leader>mr",
  sort    ="<leader>ms",
 }
 return {
  override={tags="mini-operators"},
  {index="evaluate.prefix",value=op.evaluate},
  {mode="x",               lhs=op.evaluate,                  desc="Evaluate selection"},
  {mode="n",               lhs=op.evaluate,                  desc="Evaluate operator"},
  {mode="n",               lhs=op.evaluate:gsub(".$","%0%0"),desc="Evaluate line"},
  {index="exchange.prefix",value=op.exchange},
  {mode="x",               lhs=op.exchange,                  desc="Exchange selection"},
  {mode="n",               lhs=op.exchange,                  desc="Exchange operator"},
  {mode="n",               lhs=op.exchange:gsub(".$","%0%0"),desc="Exchange line"},
  {index="multiply.prefix",value=op.multiply},
  {mode="x",               lhs=op.multiply,                  desc="Multiply selection"},
  {mode="n",               lhs=op.multiply,                  desc="Multiply operator"},
  {mode="n",               lhs=op.multiply:gsub(".$","%0%0"),desc="Multiply line"},
  {index="replace.prefix", value=op.replace},
  {mode="x",               lhs=op.replace,                   desc="Replace selection"},
  {mode="n",               lhs=op.replace,                   desc="Replace operator"},
  {mode="n",               lhs=op.replace:gsub(".$","%0%0"), desc="Replace line"},
  {index="sort.prefix",    value=op.sort},
  {mode="x",               lhs=op.sort,                      desc="Sort selection"},
  {mode="n",               lhs=op.sort,                      desc="Sort operator"},
  {mode="n",               lhs=op.sort:gsub(".$","%0%0"),    desc="Sort line"},
 }
end)(),{
 wkspec={"<leader>m",group="Mini"},
 override={tags="mini-trailspace"},
 {name=NS.mini_trailspace_trim,           lhs="<leader>m "},
 {name=NS.mini_trailspace_trim_last_lines,lhs="<leader>ml"},
},(function()
 local lhss={
  add           ="xa",
  delete        ="xd",
  find          ="xf",
  find_left     ="xF",
  highlight     ="xh",
  replace       ="xr",
  update_n_lines="xn",
 }
 local suf_last="p"
 local suf_next="n"
 return {
  override={tags="mini-surround"},
  {index="mappings.add",                       value=lhss.add},
  {desc="Add surrounding",                     lhs=lhss.add},
  {desc="Add surrounding to selection",        lhs=lhss.add,            mode="x"},
  {index="mappings.delete",                    value=lhss.delete},
  {desc="Delete surrounding",                  lhs=lhss.delete},
  {desc="Delete previous surrounding",         lhs=lhss.delete,         suffix=suf_last},
  {desc="Delete next surrounding",             lhs=lhss.delete,         suffix=suf_next},
  {index="mappings.replace",                   value=lhss.replace},
  {desc="Replace surrounding",                 lhs=lhss.replace},
  {desc="Replace previous surrounding",        lhs=lhss.replace,        suffix=suf_last},
  {desc="Replace next surrounding",            lhs=lhss.replace,        suffix=suf_next},
  {index="mappings.highlight",                 value=lhss.highlight},
  {desc="Highlight surrounding",               lhs=lhss.highlight},
  {desc="Highlight previous surrounding",      lhs=lhss.highlight,      suffix=suf_last},
  {desc="Highlight next surrounding",          lhs=lhss.highlight,      suffix=suf_next},
  {index="mappings.find",                      value=lhss.find},
  {desc="Find right surrounding",              lhs=lhss.find},
  {desc="Find previous right surrounding",     lhs=lhss.find,           suffix=suf_last},
  {desc="Find next right surrounding",         lhs=lhss.find,           suffix=suf_next},
  {index="mappings.find_left",                 value=lhss.find_left},
  {desc="Find left surrounding",               lhs=lhss.find_left},
  {desc="Find previous left surrounding",      lhs=lhss.find_left,      suffix=suf_last},
  {desc="Find next right surrounding",         lhs=lhss.find_left,      suffix=suf_next},
  {index="mappings.update_n_lines",            value=lhss.update_n_lines},
  {desc="Update `MiniSurround.config.n_lines`",lhs=lhss.update_n_lines},
  {index="mappings.suffix_last",               value=suf_last,          lazykey=false},
  {index="mappings.suffix_next",               value=suf_next,          lazykey=false},
 }
end)(),
}
