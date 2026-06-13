require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "tailwindcss",
  "intelephense",
  "bashls",
  "sqlls",
}

vim.lsp.enable(servers)
