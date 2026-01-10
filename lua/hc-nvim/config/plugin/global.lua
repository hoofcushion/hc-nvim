---@module "lazy"

local Events=require("hc-nvim.setup.event")
---@type LazySpec
return {
 -- Init
 {"folke/tokyonight.nvim",                     event="SafeState"},
 {"folke/which-key.nvim",                      event="SafeState"},
 {"folke/snacks.nvim",                         lazy=false},
 {"folke/noice.nvim",                          lazy=false},
 {"hoofcushion/hc-filter",                     name="hc-filter",                            main="hc-filter",    virtual=true,event="SafeState",config=true},

 {"echasnovski/mini.nvim"},
 {"hoofcushion/hc-nvim"},

 --- Information
 {"nvim-lualine/lualine.nvim",                 event=Events.File},
 -- {"Bekaboo/dropbar.nvim",                      event=Events.File},
 -- {"kevinhwang91/nvim-ufo",                     event=Events.File},
 -- {"chentoast/marks.nvim",                      event=Events.File},
 -- {"rainbowhxch/beacon.nvim",                   event=Events.File},

 {"smjonas/live-command.nvim",                 event="CmdlineEnter"},
 {"nacro90/numb.nvim",                         event="CmdlineEnter"},

 --- Searchers
 -- {"ibhagwan/fzf-lua"},
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 -- {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai",                       virtual=true},
 {"echasnovski/mini.operators",                virtual=true},
 {"folke/flash.nvim"},

 --- Edit
 {"hoofcushion/hc-substitute",                 name="hc-substitute",                        main="hc-substitute",virtual=true},
 {"echasnovski/mini.align",                    virtual=true},
 {"echasnovski/mini.surround",                 virtual=true},
 {"echasnovski/mini.comment",                  virtual=true},
 -- {"gbprod/yanky.nvim"},
 {"NMAC427/guess-indent.nvim",                 event=Events.File,                           config=true},
 -- {"monaqa/dial.nvim"},

 --- Tools
 {"hoofcushion/hc-func",                       name="hc-func",                              main="hc-func",      virtual=true,event=Events.File},
 {"hoofcushion/hc-analyzer",                   name="hc-analyzer",                          main="hc-analyzer",  virtual=true},
 -- {"RaafatTurki/hex.nvim"},
 {"akinsho/toggleterm.nvim"},
 -- {"chrisgrieser/nvim-various-textobjs"},
 {"nvim-neo-tree/neo-tree.nvim",               ft="directory"},
 {"nvim-pack/nvim-spectre"},
 {"s1n7ax/nvim-window-picker"},
 --- Profiller
 -- {"dstein64/vim-startuptime"},


 --- Completions
 {"L3MON4D3/LuaSnip",                          event="InsertEnter"},
 {"rafamadriz/friendly-snippets",              event=Events.LazyLoad("LuaSnip")},
 {"hrsh7th/nvim-cmp",                          event={"InsertEnter","CmdlineEnter"}},
 {"dmitmel/cmp-cmdline-history",               event={"CmdlineEnter"}},
 {"hrsh7th/cmp-buffer",                        event=Events.File},
 {"hrsh7th/cmp-cmdline",                       event="CmdlineEnter"},
 {"hrsh7th/cmp-nvim-lsp",                      event="LspAttach"},
 {"petertriho/cmp-git",                        ft={"gitcommit","octo","NeogitCommitMessage"}},
 {"saadparwaiz1/cmp_luasnip",                  event=Events.File},
 {"ray-x/cmp-treesitter",                      event=Events.File},
 {"lukas-reineke/cmp-rg",                      event=Events.File},



 --- Highlighter
 -- {"NvChad/nvim-colorizer.lua",                  event=Events.File},
 -- {"folke/todo-comments.nvim",                   event=Events.File},
 -- {"nfrid/due.nvim",                             event=Events.File},
 -- {"hiphish/rainbow-delimiters.nvim",            event=Events.File},

 --- AI
 -- {"zbirenbaum/copilot.lua"},
 {"luozhiya/fittencode.nvim",                  event="InsertEnter"},
 --- Git
 {"sindrets/diffview.nvim"},
 {"lewis6991/gitsigns.nvim",                   event=Events.RootPattern(".git")},
 {"NeogitOrg/neogit"},
 -- {"kdheepak/lazygit.nvim"},

 --- LSP etc.
 {"williamboman/mason.nvim"},
 {"WhoIsSethDaniel/mason-tool-installer.nvim"},
 {"mfussenegger/nvim-dap"},
 {"neovim/nvim-lspconfig"},
 {"nvimtools/none-ls.nvim"},

 --- LSP tools
 -- {"Wansmer/symbol-usage.nvim",                 event="LspAttach"},

 -- Neovim develop
 {"folke/lazydev.nvim",                        event=Events.NeoConfig},

 --- Treesitter
 {"nvim-treesitter/nvim-treesitter",           event=Events.Treesitter},

 -- {"andymass/vim-matchup",                      event=Events.Treesitter},
 -- {"JoosepAlviste/nvim-ts-context-commentstring"},
 -- {"folke/ts-comments.nvim"},
 {"mizlan/iswap.nvim"},
 {"nvim-treesitter/nvim-treesitter-textobjects"},
 {"altermo/ultimate-autopair.nvim",            event={"InsertEnter","CmdlineEnter"}},

 {"Wansmer/treesj"},
 {"sustech-data/wildfire.nvim"},


 --- Notebook
 {"zk-org/zk-nvim",                            event=Events.RootPattern(".zk")},
 {"MeanderingProgrammer/markdown.nvim",        ft="markdown"},
 -- {"iamcco/markdown-preview.nvim"},

 --- Libraries
 {"echasnovski/mini.icon",                     virtual=true},
}
