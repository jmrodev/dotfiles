return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "php",
        "bash",
        "sql",
        "json",
      })
      opts.highlight = {
        enable = true,
        use_languagetree = true,
      }
    end,
  },

  -- Auto-install LSP servers and formatting tools
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- LSP
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "tailwindcss-language-server",
        "intelephense",
        "bash-language-server",
        "sqlls",

        -- Formatters/Linters
        "prettier",
        "php-cs-fixer",
        "shfmt",
        "sql-formatter",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
    end,
  },

  -- Auto-close & auto-rename tags (excellent for React, HTML, PHP)
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Database management (MySQL, SQL, etc.)
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- Add Dadbod completion source to nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, { name = "vim-dadbod-completion" })
    end,
  },

  -- ─── VS CODE-LIKE FEATURES ───────────────────────────────────────────

  -- 1. Trouble.nvim (VS Code's "Problems" panel for errors & warnings)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      {
        "<leader>q",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics / Problems Panel (Trouble)",
      },
      {
        "<leader>Q",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols / Structure (Trouble)",
      },
    },
  },

  -- 2. Grug-far.nvim (VS Code's Project-wide Search & Replace sidebar)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      {
        "<leader>sr",
        "<cmd>GrugFar<cr>",
        desc = "Search and Replace in Files (GrugFar)",
      },
    },
  },

  -- 3. Outline.nvim (VS Code's Class Outline sidebar panel)
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>ol", "<cmd>Outline<CR>", desc = "Toggle Code Outline Sidebar" },
    },
    opts = {},
  },

  -- 4. Neoscroll (VS Code's Smooth scrolling)
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require("neoscroll").setup({
        easing_function = "quadratic",
      })
    end,
  },
}
