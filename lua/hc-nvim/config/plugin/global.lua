---@module "lazy"

local Events=(require("hc-nvim.setup.event").Events or {})
---@type LazySpec
return {
 -- UI
 {"folke/tokyonight.nvim",                     lazy=false},
 {"folke/snacks.nvim",                         event="UIEnter"},
 {"folke/which-key.nvim",                      event="UIEnter"},
 {"folke/noice.nvim",                          event="UIEnter"},
 {"nvim-lualine/lualine.nvim",                 event="UIEnter"},
 {"hoofcushion/hc-filter",                     virtual=true,                                main="hc-filter",                   event="SafeState",                 dependencies="hoofcushion/hc-nvim"},

 {"echasnovski/mini.nvim"},
 {"hoofcushion/hc-nvim"},

 --- Information
 {"Bekaboo/dropbar.nvim",                      event={"BufReadPost","BufNewFile"}},
 {"chentoast/marks.nvim",                      event={"BufReadPost","BufNewFile"}},

 {"smjonas/live-command.nvim",                 event="CmdlineEnter"},
 {"nacro90/numb.nvim",                         event="CmdlineEnter"},

 --- Searchers
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 -- {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai",                       virtual=true,                                dependencies="echasnovski/mini.nvim"},
 {"echasnovski/mini.operators",                virtual=true,                                dependencies="echasnovski/mini.nvim"},
 {"folke/flash.nvim"},

 --- Edit
 {"hoofcushion/hc-substitute",                 virtual=true,                                main="hc-substitute",               dependencies="hoofcushion/hc-nvim"},
 {"echasnovski/mini.align",                    virtual=true,                                dependencies="echasnovski/mini.nvim"},
 {"echasnovski/mini.surround",                 virtual=true,                                dependencies="echasnovski/mini.nvim"},
 {"echasnovski/mini.comment",                  virtual=true,                                dependencies="echasnovski/mini.nvim"},
 {"NMAC427/guess-indent.nvim",                 event={"BufReadPost","BufNewFile"},          config=true},
 {"monaqa/dial.nvim"},

 --- Tools
 {"hoofcushion/hc-func",                       virtual=true,                                main="hc-func",                     event={"BufReadPost","BufNewFile"},dependencies="hoofcushion/hc-nvim"},
 {"hoofcushion/hc-analyzer",                   virtual=true,                                main="hc-analyzer",                 dependencies="hoofcushion/hc-nvim"},
 {"akinsho/toggleterm.nvim"},
 {"nvim-neo-tree/neo-tree.nvim",               event={"BufReadPost","BufNewFile"}},
 --- Profiller
 -- {"dstein64/vim-startuptime"},


 --- Completions
 {"L3MON4D3/LuaSnip",                          event="InsertEnter"},
 {"rafamadriz/friendly-snippets",              event=Events.LazyLoad("LuaSnip")},
 {"hrsh7th/nvim-cmp",                          event={"InsertEnter","CmdlineEnter"}},
 {"dmitmel/cmp-cmdline-history",               event={"CmdlineEnter"}},
 {"hrsh7th/cmp-buffer",                        event={"BufReadPost","BufNewFile"}},
 {"hrsh7th/cmp-cmdline",                       event="CmdlineEnter"},
 {"hrsh7th/cmp-nvim-lsp",                      event="LspAttach"},
 {"petertriho/cmp-git",                        ft={"gitcommit","octo","NeogitCommitMessage"}},
 {"saadparwaiz1/cmp_luasnip",                  event={"BufReadPost","BufNewFile"}},
 {"ray-x/cmp-treesitter",                      event={"BufReadPost","BufNewFile"}},
 -- {"lukas-reineke/cmp-rg",                      event={"BufReadPost","BufNewFile"}},


 --- AI
 {"luozhiya/fittencode.nvim",                  event="InsertEnter"},
 --- Git
 {"sindrets/diffview.nvim"},
 {"lewis6991/gitsigns.nvim",                   event=Events.RootPattern(".git")},
 {"NeogitOrg/neogit"},

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

 {"andymass/vim-matchup",                      event=Events.Treesitter},
 {"JoosepAlviste/nvim-ts-context-commentstring"},
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
 {"echasnovski/mini.icon",                     virtual=true,                                dependencies="echasnovski/mini.nvim"},
}
