require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>db", "<cmd>DBUIToggle<cr>", { desc = "Database UI Toggle" })

-- Safe buffer close to prevent E517 error in Neovim 0.12+
map("n", "<leader>x", function()
  pcall(function()
    require("nvchad.tabufline").close_buffer()
  end)
end, { desc = "buffer close (safe)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
