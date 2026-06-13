require "nvchad.options"

-- Prepend Neovim-private wrapper to PATH so Mason routes npm calls to pnpm
local sep = ":"
local nvim_bin_path = vim.fn.stdpath "config" .. "/bin"
vim.env.PATH = nvim_bin_path .. sep .. vim.env.PATH

-- Generate wrappers for pnpm-installed binaries in Mason
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
local uv = vim.uv or vim.loop

local function generate_pnpm_wrappers()
  local handle = uv.fs_scandir(mason_bin)
  if not handle then return end

  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end

    local filepath = mason_bin .. "/" .. name
    local stat = uv.fs_lstat(filepath)
    if stat and stat.type == "link" then
      local target = uv.fs_readlink(filepath)
      if target then
        -- Resolve relative target if necessary
        local abs_target = target
        if not target:match "^/" then
          abs_target = mason_bin .. "/" .. target
        end
        abs_target = vim.fn.resolve(abs_target)

        -- If the target points to a pnpm node_modules/.bin wrapper
        if abs_target:match "node_modules/%.bin/" then
          local wrapper_path = nvim_bin_path .. "/" .. name
          local wrapper_content = string.format("#!/bin/bash\nexec %q \"$@\"\n", abs_target)

          -- Write wrapper if it doesn't exist or is different
          local f = io.open(wrapper_path, "r")
          local current_content = f and f:read "*a" or ""
          if f then f:close() end

          if current_content ~= wrapper_content then
            local wf = io.open(wrapper_path, "w")
            if wf then
              wf:write(wrapper_content)
              wf:close()
              uv.fs_chmod(wrapper_path, 493) -- 0755 in octal
            end
          end
        end
      end
    end
  end
end

-- Run it on startup
vim.schedule(generate_pnpm_wrappers)

-- add yours here!
-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
