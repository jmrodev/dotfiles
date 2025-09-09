---@type NvPluginSpec[]
local plugins = {
  -- ===============================
  -- FOLDS
  -- ===============================
  {
    "kevinhwang91/nvim-ufo",
    event = "VimEnter",
    init = function()
      vim.o.foldcolumn = "auto"
      vim.o.foldlevel = 99 -- Using ufo provider need a large value
      vim.o.foldlevelstart = 99
      vim.o.foldnestmax = 0
      vim.o.foldenable = true
      vim.o.foldmethod = "indent"

      vim.opt.fillchars = {
        fold = " ",
        foldopen = " ",
        foldsep = " ",
        foldclose = " ",
        stl = " ",
        eob = " ",
      }
    end,
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        opts = function()
          local builtin = require "statuscol.builtin"
          return {
            relculright = true,
            bt_ignore = { "nofile", "prompt", "terminal", "packer" },
            ft_ignore = {
              "NvimTree",
              "dashboard",
              "nvcheatsheet",
              "dapui_watches",
              "dap-repl",
              "dapui_console",
              "dapui_stacks",
              "dapui_breakpoints",
              "dapui_scopes",
              "help",
              "vim",
              "alpha",
              "dashboard",
              "neo-tree",
              "Trouble",
              "noice",
              "lazy",
              "toggleterm",
            },
            segments = {
              -- Segment: Add padding
              {
                text = { " " },
              },
              -- Segment: Fold Column
              {
                text = { builtin.foldfunc },
                click = "v:lua.ScFa",
                maxwidth = 1,
                colwidth = 1,
                auto = false,
              },
              -- Segment: Add padding
              {
                text = { " " },
              },
              -- Segment : Show signs with one character width
              {
                sign = {
                  name = { ".*" },
                  maxwidth = 1,
                  colwidth = 1,
                },
                auto = true,
                click = "v:lua.ScSa",
              },
              -- Segment: Show line number
              {
                text = { " ", " ", builtin.lnumfunc, " " },
                click = "v:lua.ScLa",
                condition = { true, builtin.not_empty },
              },
              -- Segment: GitSigns exclusive
              {
                sign = {
                  namespace = { "gitsign.*" },
                  maxwidth = 1,
                  colwidth = 1,
                  auto = false,
                },
                click = "v:lua.ScSa",
              },
              -- Segment: Add padding
              {
                text = { " " },
                hl = "Normal",
                condition = { true, builtin.not_empty },
              },
            },
          }
        end,
      },
    },
    opts = {
      close_fold_kinds_for_ft = { default = { "imports" } },
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
  },

  {
    "jghauser/fold-cycle.nvim",
    opts = {},
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>a", function()
        require("fold-cycle").toggle_all()
      end, { desc = "Toggle fold" })
    end,
  },

  {
    "razak17/tailwind-fold.nvim",
    ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
    opts = {
      min_chars = 50,
    },
  },

  {
    "anuvyklack/fold-preview.nvim",
    opts = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
  },

  {
    "chrisgrieser/nvim-origami",
    event = "BufReadPost",
    opts = {
      keepFoldsAcrossSessions = true,
      pauseFoldsOnSearch = true,
    },
    config = function() end,
  },

  -- ===============================
  -- GIT
  -- ===============================
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
  },

  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      {
        "sindrets/diffview.nvim",
        config = true,
      },
    },
  },

  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    ft = { "diff" },
    opts = {
      signs = { section = { "", "" }, item = { "", "" } },
      disable_commit_confirmation = true,
      integrations = { diffview = true },
    },
    config = function(_, opts)
      require("neogit").setup(opts)
      dofile(vim.g.base46_cache .. "git")
      dofile(vim.g.base46_cache .. "neogit")
    end,
  },

  -- ===============================
  -- EDITOR
  -- ===============================
  {
    "hiphish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  {
    "lewis6991/satellite.nvim",
    event = "BufWinEnter",
    opts = { excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify", "neo-tree" } },
  },

  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      callbacks = {
        before_saving = function()
          -- save global autoformat status
          vim.g.OLD_AUTOFORMAT = vim.g.autoformat_enabled
          vim.g.autoformat_enabled = false
          vim.g.OLD_AUTOFORMAT_BUFFERS = {}
          -- disable all manually enabled buffers
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.b[bufnr].autoformat_enabled then
              table.insert(vim.g.OLD_BUFFER_AUTOFORMATS, bufnr)
              vim.b[bufnr].autoformat_enabled = false
            end
          end
        end,
        after_saving = function()
          -- restore global autoformat status
          vim.g.autoformat_enabled = vim.g.OLD_AUTOFORMAT
          -- reenable all manually enabled buffers
          for _, bufnr in ipairs(vim.g.OLD_AUTOFORMAT_BUFFERS or {}) do
            vim.b[bufnr].autoformat_enabled = true
          end
        end,
      },
    },
  },

  {
    "m-demare/hlargs.nvim",
    event = "BufWinEnter",
    config = function()
      require("hlargs").setup {
        hl_priority = 200,
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      throttle = true,
      max_lines = 0,
      patterns = {
        default = {
          "class",
          "function",
          "method",
        },
      },
    },
  },

  {
    "rainbowhxch/beacon.nvim",
    event = "CursorMoved",
    cond = function()
      -- Don't load in neovide
      return not vim.g.neovide
    end,
  },

  {
    "code-biscuits/nvim-biscuits",
    event = "BufReadPost",
    opts = {
      show_on_start = false,
      cursor_line_only = true,
      default_config = {
        min_distance = 10,
        max_length = 50,
        prefix_string = " 󰆘 ",
        prefix_highlight = "Comment",
        enable_linehl = true,
      },
    },
  },

  {
    "Wansmer/treesj",
    keys = { { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle Treesitter Join" } },
    cmd = { "TSJToggle" },
    opts = { use_default_keymaps = false },
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>tt", "<CMD>TSJToggle<CR>", { desc = "Toggle Treesitter Join/Split" })
    end,
  },

  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    config = true,
  },

  {
    "RRethy/vim-illuminate",
    event = { "CursorHold", "CursorHoldI" },
    dependencies = "nvim-treesitter",
    config = function()
      require("illuminate").configure {
        under_cursor = true,
        max_file_lines = nil,
        delay = 100,
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
        filetypes_denylist = {
          "NvimTree",
          "Trouble",
          "Outline",
          "TelescopePrompt",
          "Empty",
          "dirvish",
          "fugitive",
          "alpha",
          "packer",
          "neogitstatus",
          "spectre_panel",
          "toggleterm",
          "DressingSelect",
          "aerial",
        },
      }
    end,
  },

  {
    "gbprod/cutlass.nvim",
    event = "BufReadPost",
    opts = {
      cut_key = "x",
      override_del = true,
      exclude = {},
      registers = {
        select = "_",
        delete = "_",
        change = "_",
      },
    },
  },

  {
    "kevinhwang91/nvim-fundo",
    event = "VeryLazy",
    opts = {},
    build = function()
      require("fundo").install()
    end,
  },

  -- ===============================
  -- FILE EXPLORER
  -- ===============================
  {
    "stevearc/oil.nvim",
    opts = {},
    event = "VeryLazy",
    cmd = "Oil",
    keys = {
      {
        "<leader>fl",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory",
      },
    },
  },

  -- ===============================
  -- LSP
  -- ===============================
  {
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
    init = function()
      vim.g.code_action_menu_show_details = true
      vim.g.code_action_menu_show_diff = true
      vim.g.code_action_menu_show_action_kind = true
    end,
    config = function()
      dofile(vim.g.base46_cache .. "git")
    end,
  },

  {
    "0oAstro/dim.lua",
    event = "LspAttach",
    config = function()
      require("dim").setup {}
    end,
  },

  {
    "utilyre/barbecue.nvim",
    event = "LspAttach",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {},
  },

  {
    "jinzhongjia/LspUI.nvim",
    event = "LspAttach",
    opts = {},
  },

  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {
      code_action = {
        show_server_name = false,
        num_shortcut = false,
      },
      request_timeout = 2000,
      lightbulb = {
        enable = true,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = false,
      },
      diagnostic = {
        show_code_action = true,
      },
      symbol_in_winbar = {
        enable = true,
        separator = " ",
        hide_keyword = true,
        show_file = true,
        folder_level = 2,
        respect_root = false,
        color_mode = true,
      },
      ui = {
        title = false,
        expand = "",
        collapse = "",
        code_action = "",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy", "BufRead" },
    config = function()
      local on_attach = require("nvchad.configs.lspconfig").on_attach
      local capabilities = require("nvchad.configs.lspconfig").capabilities
      local lspconfig = require "lspconfig"

      local servers = { "html", "cssls", "clangd" }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              on_attach = function(client, bufnr)
                on_attach(client, bufnr)
              end,
              capabilities = capabilities,
            })
          end,
          ["clangd"] = function()
            lspconfig.clangd.setup({
              cmd = {
                "clangd",
                "--offset-encoding=utf-16",
                "--enable-config",
              },
              on_attach = function(client, bufnr)
                on_attach(client, bufnr)
              end,
              capabilities = capabilities,
            })
          end,
          ["lua_ls"] = function() end,
        },
      })
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig",
    },
  },

  {
    "Fildo7525/pretty_hover",
    keys = { "<leader>k" },
    config = true,
  },

  -- ===============================
  -- DIAGNOSTICS
  -- ===============================
  {
    "chikko80/error-lens.nvim",
    event = "LspAttach",
    opts = {},
  },

  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
    dependencies = {
      {
        "folke/todo-comments.nvim",
        opts = {}
      }
    },
    opts = {},
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>t", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })
      map("n", "<leader>td", "<CMD>TodoTrouble keywords=TODO,FIX,FIXME,BUG,TEST,NOTE<CR>", { desc = "Todo/Fix/Fixme" })
    end,
  },

  -- ===============================
  -- TOOLS
  -- ===============================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "debugloop/telescope-undo.nvim",
        config = function()
          local map = vim.keymap.set
          map("n", "<leader>fu", "<CMD>Telescope undo<CR>", { desc = "Find undo" })
          require("telescope").load_extension "undo"
        end,
      },
    },
    opts = {
      extensions_list = { "fzf", "undo" },
    },
  },

  {
    "andweeb/presence.nvim",
    event = "VimEnter",
    opts = {},
  },

  -- ===============================
  -- COMPLETION
  -- ===============================
  {
    "hrsh7th/nvim-cmp",
    config = function(_, opts)
      -- Add multiple completion sources
      table.insert(opts.sources, { name = "conjure" })

      -- Custom mapping for Tab to prioritize Copilot
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = function(fallback)
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept()
          else
            fallback()
          end
        end,
      })

      require("cmp").setup(opts)
    end,
    dependencies = {
      {
        "Olical/conjure",
        ft = {
          "clojure",
          "fennel",
          "janet",
          "hy",
          "julia",
          "racket",
          "scheme",
          "lua",
          "lisp",
          "python",
          "rust",
          "sql",
        },
        opts = {},
        config = function()
          require("conjure.main").main()
          require("conjure.mapping")["on-filetype"]()
        end,
        dependencies = { "PaterJason/cmp-conjure" },
      },
      
      
    },
  },

  {
    "zbirenbaum/copilot.lua",
    event = { "InsertEnter" },
    cmd = { "Copilot" },
    opts = {
      suggestion = {
        auto_trigger = true,
      }
    }
  },

  -- ===============================
  -- MOTION
  -- ===============================
  {
    "MattesGroeger/vim-bookmarks",
    cmd = {
      "BookmarkToggle",
      "BookmarkAnnotate",
      "BookmarkNext",
      "BookmarkPrev",
      "BookmarkShowAll",
      "BookmarkClearAll",
      "BookmarkClear",
    },
    init = function()
      vim.g.bookmark_sign = ""
    end,
  },

  {
    "ggandor/leap.nvim",
    keys = {
      { "s",  mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S",  mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function(_, opts)
      local leap = require "leap"
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
    end,
  },

  {
    "smoka7/hop.nvim",
    cmd = { "HopWord", "HopLine", "HopLineStart", "HopWordCurrentLine" },
    opts = { keys = "etovxqpdygfblzhckisuran" },
    init = function()
      local map = vim.keymap.set
      map("n", "<leader><leader>w", "<CMD> HopWord <CR>", { desc = "Hint all words" })
      map("n", "<leader><leader>t", "<CMD> HopNodes <CR>", { desc = "Hint Tree" })
      map("n", "<leader><leader>c", "<CMD> HopLineStart<CR>", { desc = "Hint Columns" })
      map("n", "<leader><leader>l", "<CMD> HopWordCurrentLine<CR>", { desc = "Hint Line" })
    end,
  },

  {
    "ThePrimeagen/harpoon",
    cmd = "Harpoon",
  },

  {
    "karb94/neoscroll.nvim",
    keys = { "<C-d>", "<C-u>" },
    opts = { mappings = {
      "<C-u>",
      "<C-d>",
    } },
  },
}

return plugins