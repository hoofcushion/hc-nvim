local Config=require("hc-nvim.config")
return {
 filesystem={
  bind_to_cwd=true,
  follow_current_file={enabled=true},
  use_libuv_file_watcher=true,
  commands={
   -- over write default 'delete' command to 'trash'.
   trash=vim.fn.executable("trash")==1 and function(state)
     local inputs=require("neo-tree.ui.inputs")
     local path=state.tree:get_node().path
     local msg="Are you sure you want to trash "..path
     inputs.confirm(msg,function(confirmed)
      if not confirmed then return end
      vim.fn.system({"trash",vim.fn.fnameescape(path)})
      require("neo-tree.sources.manager").refresh(state.name)
     end)
    end
    or nil,
   -- over write default 'delete_visual' command to 'trash' x n.
   trash_visual=vim.fn.executable("trash")==1 and function(state,selected_nodes)
     local inputs=require("neo-tree.ui.inputs")
     local msg="Are you sure you want to trash "..#selected_nodes.." files ?"
     inputs.confirm(msg,function(confirmed)
      if not confirmed then return end
      for _,node in ipairs(selected_nodes) do
       vim.fn.system({"trash",vim.fn.fnameescape(node.path)})
      end
      require("neo-tree.sources.manager").refresh(state.name)
     end)
    end
    or nil,
   open_external=function(state)
    local path=state.tree:get_node().path
    vim.ui.open(path)
   end,
   open_external_visual=function(state,selected_nodes)
    local inputs=require("neo-tree.ui.inputs")
    inputs.confirm(
     ("Are you sure you want to open %s files externally?"):format(#selected_nodes),
     function(confirmed)
      if not confirmed then return end
      for _,node in ipairs(selected_nodes) do
       vim.ui.open(node.path)
      end
     end
    )
   end,
   yank_filename=function(state)
    local path=state.tree:get_node().path
    vim.fn.setreg(vim.v.register,path,"c")
   end,
   yank_filename_visual=
    function(state,selected_nodes)
     local paths={}
     for _,node in ipairs(selected_nodes) do
      table.insert(paths,node.path)
     end
     vim.fn.setreg(vim.v.register,table.concat(paths,"\n"),"c")
    end,
  },
 },
 sources={
  "document_symbols",
  "filesystem",
  "buffers",
  "git_status",
 },
 default_component_configs={
  indent={
   with_markers=false,
   indent_size=1,
   with_expanders=true,
  },
 },
 popup_border_style=require("hc-nvim.rsc").border[Config.ui.border],
 window={
  position="right",
  width=("%f%%"):format(Config.ui.window.horizontal*100),
  mappings={
   ["<space>"]=false,
   ["O"]={"open_external",desc="Open file externally"},
   ["P"]={"toggle_preview",config={use_float=false}},
   ["T"]=vim.fn.executable("trash")==1 and {"trash",desc="Trash file"} or nil,
   ["Y"]={"yank_filename",desc="Copy filename"},
   ["h"]="close_node",
   ["l"]="open",
  },
 },
 document_symbols={
  client_filters="all",
 },
 source_selector={
  winbar=true,
  statusline=true,
  sources={
   {source="filesystem",display_name=" 󰉓 File"},
   {source="buffers",display_name=" 󰈚 Buf"},
   {source="git_status",display_name=" 󰊢 Git"},
   {source="document_symbols",display_name="  Symbol"},
  },
 },
}
