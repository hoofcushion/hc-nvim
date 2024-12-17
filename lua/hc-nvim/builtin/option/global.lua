return {
 g={
  yaml_recommended_style=0,
  localmapleader="\\",
  mapleader=" ",
 },
 o={
  --- Position ---
  number=true,         -- Display line numbers
  relativenumber=true, -- Display relative line numbers
  wrap=false,          -- Disable line wrap
  signcolumn="auto",

  --- UI ---
  termguicolors=true, -- Use color
  guifont="MonaspiceAr Nerd Font:h10:b",
  guicursor={
   "n:block",
   "v:block",
   "ve:ver25",
   "o:ver25",
   "i:ver25",
   "r:ver25",
   "c:ver25",
   "ci:ver25",
   "cr:ver25",
   "sm:ver25",
  },

  --- Window ---
  splitbelow=true, -- Put new windows at below
  splitright=true, -- Put new windows at right
  laststatus=3,    -- Global statusline shared in every window

  --- Display ---
  list=true,  -- Show some invisible characters -- Show invisible characters such as tabs and spaces
  listchars={ -- Define characters for different types of invisible characters
   eol="$",   -- Line ending character
   tab="| ",  -- Tab character
   space="·", -- Space character
   -- multispace="---+",           -- Multiple consecutive space character
   -- lead=":",                    -- Leading space character
   -- leadmultispace="---+",       -- Leading multiple consecutive space character
   -- trail="-",                   -- Trailing space character
   -- extends=">",                 -- Character when exceeding screen on the right
   -- precedes="<",                -- Character when there is text before the first visible column
   -- conceal="*",                 -- Character for hidden characters
   nbsp="_", -- Character for non-breaking space
  },

  --- Edit ---
  whichwrap="b,s,<,>,h,l",
  confirm=true,                      -- Confirm to save changes before exiting modified buffer
  spell=false,                       -- Disable spell check
  spelllang={vim.o.spelllang,"cjk"}, -- Set spell check language to English
  virtualedit="block",               -- Allow cursor to move where there is no text in visual block mode
  clipboard="unnamedplus",           -- Sync with system clipboard -- Use system clipboard for copy and paste

  --- Indentation ---
  tabstop=1,         -- How many spaces that tab count for
  softtabstop=1,     -- How many spaces that tab will be insert if it sets higher than 0
  shiftwidth=1,      -- How many spaces that a indentation needs
  expandtab=true,    -- Use spaces instead of tabs for indentation
  autoindent=true,   -- Automatically indent new lines based on previous lines
  smartindent=false, -- Smart indent new lines by context

  --- Search ---
  hlsearch=true,   -- Enable search highlighting
  ignorecase=true, -- Ignore case when searching
  smartcase=true,  -- Don't ignore case with capital letters

  --- File ---
  undofile=true,    -- Enable undo history and save it in a file
  undolevels=10000, -- Set undo levels to keep a large history of changes
  fileencodings={"utf-8,gbk,gb18030,gb2312,big5",vim.o.fileencodings},

  --- Fold ---
  foldlevel=99,
  foldlevelstart=99,
  foldcolumn="0",
 },
}
