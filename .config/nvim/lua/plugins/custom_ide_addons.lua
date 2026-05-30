-- Configuraciones del IDE Generadas por la Suite de Instaladores de jmro
-- Soporta de forma nativa e inteligente LazyVim y NvChad en caliente.

local is_nvchad = pcall(require, "nvconfig")

local plugins = {
  -- 1. Asegurar Instalación Automática de LSPs mediante Mason
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua", "shfmt", "html-lsp", "css-lsp", "vtsls", "tailwindcss-language-server", "prettier", "pyright", "black", "intelephense", "php-cs-fixer", "bash-language-server", "gopls", "dockerfile-language-server"
      },
    },
  },
}

-- Inyectar tema visual si no es NvChad
if not is_nvchad then
  if "gruvbox" ~= "" then
    table.insert(plugins, { "ellisonleao/gruvbox.nvim", priority = 1000 })
    table.insert(plugins, {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "gruvbox",
      },
    })
  end
end

-- 2. Configurar Servidores LSP e integrarlos con el autocompletado
table.insert(plugins, {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {}, -- Configuración para LazyVim (vtsls es mejor para Node/TS)
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
    local lspconfig = require("lspconfig")
    
    -- Si es NvChad, usar sus hooks específicos
    if is_nvchad then
      local status, nv_lsp = pcall(require, "nvchad.configs.lspconfig")
      if status then
        for server, server_opts in pairs(opts.servers) do
          server_opts.on_attach = nv_lsp.on_attach
          server_opts.on_init = nv_lsp.on_init
          server_opts.capabilities = nv_lsp.capabilities
          lspconfig[server].setup(server_opts)
        end
      end
    else
      -- Si es LazyVim, el plugin ya maneja el setup mediante 'opts.servers'
      -- Pero podemos añadir personalizaciones aquí si fuera necesario
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
