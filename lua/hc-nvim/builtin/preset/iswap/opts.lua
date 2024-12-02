return {
 -- The keys that will be used as a selection, in order
 -- default 'asdfghjklqwertyuiopzxcvbnm'
 keys="asdfghjklqwertyuiopzxcvbnm",
 -- Grey out the rest of the text when making a selection
 -- "disable" or "enabled"
 -- default 'enabled'
 grey="enabled",
 -- Highlight group for the sniping value (asdf etc.)
 -- default 'Search'
 hl_snipe="Search",
 -- Highlight group for the visual selection of terms
 -- default 'Visual'
 hl_selection="Visual",
 -- Highlight group for the greyed background
 -- default 'Comment'
 hl_grey="Comment",
 -- Post-operation flashing highlight style,
 -- either 'simultaneous' or 'sequential', or false to disable
 -- default 'sequential'
 flash_style="sequential",
 -- Highlight group for flashing highlight afterward
 -- default 'IncSearch'
 hl_flash="IncSearch",
 -- Move cursor to the other element in ISwap*With commands
 -- default false
 move_cursor=true,
 -- Automatically swap with only two arguments
 -- default nil
 autoswap=nil,
 -- Other default options you probably should not change:
 debug=nil,
 hl_grey_priority="1000",
}
