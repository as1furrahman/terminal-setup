-- ~/.config/nvim/init.lua
-- Neovim Configuration with LazyVim
-- Part of: Cross-Distro Terminal Setup

-- ============================================================================
-- Bootstrap lazy.nvim (Plugin Manager)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Leader Key (must be set before lazy)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============================================================================
-- Basic Options (before LazyVim loads)
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- ============================================================================
-- Setup lazy.nvim with LazyVim
-- ============================================================================
require("lazy").setup({
  spec = {
    -- Import LazyVim and its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        -- colorscheme can be set here (theming deferred for now)
        -- colorscheme = "catppuccin",
      },
    },

    -- Import LazyVim extras (optional, add as needed)
    -- { import = "lazyvim.plugins.extras.lang.python" },
    -- { import = "lazyvim.plugins.extras.lang.rust" },
    -- { import = "lazyvim.plugins.extras.lang.go" },

    -- Your custom plugins can go here
    -- { "github/copilot.vim" },
  },

  defaults = {
    lazy = false,
    version = false, -- Use latest git commits
  },

  install = {
    -- Try to load colorscheme when installing missing plugins
    colorscheme = { "tokyonight", "habamax" },
  },

  checker = {
    enabled = true,     -- Check for plugin updates
    notify = false,     -- Don't notify on startup
  },

  performance = {
    rtp = {
      -- Disable some rtp plugins for faster startup
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ============================================================================
-- Additional Keymaps (LazyVim provides many defaults)
-- ============================================================================

-- Quick save
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })

-- Quick quit
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Clear search highlight with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Better window navigation (if not already set by LazyVim)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ============================================================================
-- Note: LazyVim provides extensive defaults including:
-- - File explorer (neo-tree)
-- - Fuzzy finder (telescope)
-- - LSP support
-- - Autocompletion
-- - Git integration
-- - Which-key for keybind hints
-- - And much more...
--
-- Press <space> to see available keybinds via which-key
-- ============================================================================
