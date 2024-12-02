--- Module: NvimWorkspace
--- Imitate the workspace feature like VS code.
--- The concept of a workspace enables VS Code to:
---     Configure settings that only apply to a specific folder or folders but not others.
---     Persist task and debugger launch configurations that are only valid in the context of that workspace.
---     Store and restore UI state associated with that workspace (for example, the files that are opened).
---     Selectively enable or disable extensions only for that workspace.
local NvimWorkspace={
 file=".neovim.lua"
}
function NvimWorkspace.init()
 --- Make sure .neovim.lua exist.
end
