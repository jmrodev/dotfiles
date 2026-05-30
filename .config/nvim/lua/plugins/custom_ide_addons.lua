-- Configuraciones del IDE Generadas por la Suite de Instaladores de jmro
-- Optimizada para Neovim v0.11+ (LazyVim Native Support)

local is_nvchad = pcall(require, "nvconfig")

local plugins = {
  -- 1. Asegurar Instalación Automática de LSPs mediante Mason
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua", "shfmt", "html-lsp", "css-lsp", "vtsls", "tailwindcss-language-server", 
        "prettier", "pyright", "black", "intelephense", "php-cs-fixer", 
        "bash-language-server", "gopls", "dockerfile-language-server"
      },
    },
  },
}

-- Inyectar tema visual si no es NvChad (Para LazyVim puro)
if not is_nvchad then
  table.insert(plugins, { "ellisonleao/gruvbox.nvim", priority = 1000 })
  table.insert(plugins, {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  })
end

-- 2. Configurar Servidores LSP (Modern Way)
table.insert(plugins, {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {}, 
      html = {},
      cssls = {},
      tailwindcss = {},
      pyright = {},
      intelephense = {},
      bashls = {},
      gopls = {},
      dockerls = {},
    },
  },
  config = function(_, opts)
    -- Si es NvChad, mantener compatibilidad legacy
    if is_nvchad then
      local status, nv_lsp = pcall(require, "nvchad.configs.lspconfig")
      if status then
        local lspconfig = require("lspconfig")
        for server, server_opts in pairs(opts.servers) do
          server_opts.on_attach = nv_lsp.on_attach
          server_opts.on_init = nv_lsp.on_init
          server_opts.capabilities = nv_lsp.capabilities
          lspconfig[server].setup(server_opts)
        end
      end
    else
      -- En LazyVim / Neovim 0.11+, el plugin ya maneja el setup.
      -- No hacemos 'require("lspconfig")' global para evitar el aviso de deprecación.
      -- LazyVim usará automáticamente 'opts.servers' para configurar todo.
    end
  end
})

-- 3. Terminal Flotante Integrada (ToggleTerm)
table.insert(plugins, {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      direction = "float",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        winblend = 3,
      },
    })
  end,
  keys = {
    { "<leader>ft", "<cmd>ToggleTerm direction=float<cr>", desc = "Abrir Terminal Flotante" },
    { "<leader>fh", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Abrir Terminal Horizontal" },
  }
})

-- 4. Inteligencia Artificial (GitHub Copilot)
table.insert(plugins, {
  "github/copilot.vim",
  lazy = false,
  init = function()
    vim.g.copilot_version = false
  end,
})

-- 5. Previsualización de Markdown en Vivo
table.insert(plugins, {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && pnpm install --no-lockfile",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
})

return plugins
