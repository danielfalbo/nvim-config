-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {
  -- Colorschemes
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- mocha, macchiato, frappe, latte
    },
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night", -- storm, moon, night, day
    },
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "dark", -- dark, darker, cool, deep, warm, warmer, light
    },
  },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
    },
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      -- wave, dragon, lotus
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      -- dark, light
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      variant = "moon", -- auto, main, moon, dawn
    },
  },
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
  },
  {
    "neanias/everforest-nvim",
    priority = 1000,
    config = function()
      require("everforest").setup {
        background = "hard", -- hard, medium, soft
      }
    end,
  },
  {
    "shaunsingh/solarized.nvim",
    priority = 1000,
    config = function()
      vim.g.solarized_italic_comments = true
      vim.g.solarized_italic_keywords = true
      vim.g.solarized_italic_functions = false
      vim.g.solarized_italic_variables = false
      vim.g.solarized_contrast = "normal" -- normal|high|low
      vim.g.solarized_bold = true
      vim.g.solarized_underline = true
      vim.g.solarized_italic = true
      vim.g.solarized_termtrans = false
      vim.g.solarized_diffmode = "normal" -- normal|high|low
    end,
  },
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    opts = {
      dimming = {
        alpha = 0.25, -- amount of dimming
      },
      context = 10, -- amount of lines we will try to show around the current line
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function() require("nvim-surround").setup {} end,
  },

  -- -- == Examples of Adding Plugins ==
  --
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            -- " █████  ███████ ████████ ██████   ██████ ",
            -- "██   ██ ██         ██    ██   ██ ██    ██",
            -- "███████ ███████    ██    ██████  ██    ██",
            -- "██   ██      ██    ██    ██   ██ ██    ██",
            -- "██   ██ ███████    ██    ██   ██  ██████ ",
            -- "",
            -- "███    ██ ██    ██ ██ ███    ███",
            -- "████   ██ ██    ██ ██ ████  ████",
            -- "██ ██  ██ ██    ██ ██ ██ ████ ██",
            -- "██  ██ ██  ██  ██  ██ ██  ██  ██",
            -- "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
      indent = {
        enabled = false, -- disable indent guides by default
      },
    },
  },

  -- -- You can disable default plugins as follows:
  -- { "max397574/better-escape.nvim", enabled = false },

  -- -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom luasnip configuration such as filetype extend or custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --   end,
  -- },
  --
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom autopairs configuration such as custom rules
  --     local npairs = require "nvim-autopairs"
  --     local Rule = require "nvim-autopairs.rule"
  --     local cond = require "nvim-autopairs.conds"
  --     npairs.add_rules(
  --       {
  --         Rule("$", "$", { "tex", "latex" })
  --           -- don't add a pair if the next character is %
  --           :with_pair(cond.not_after_regex "%%")
  --           -- don't add a pair if  the previous character is xxx
  --           :with_pair(
  --             cond.not_before_regex("xxx", 3)
  --           )
  --           -- don't move right when repeat character
  --           :with_move(cond.none())
  --           -- don't delete if the next character is xx
  --           :with_del(cond.not_after_regex "xx")
  --           -- disable adding a newline when you press <cr>
  --           :with_cr(cond.none()),
  --       },
  --       -- disable for .vim files, but it work for another filetypes
  --       Rule("a", "a", "-vim")
  --     )
  --   end,
  -- },
}
