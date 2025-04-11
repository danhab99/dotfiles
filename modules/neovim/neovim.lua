-- Ensure termguicolors is enabled
vim.opt.termguicolors = true

-- Set your colorscheme
vim.cmd([[colorscheme tokyonight]])

-- Configure transparent.nvim
require("transparent").setup({
  extra_groups = {
    "NormalFloat",       -- Floating windows
    "NvimTreeNormal",    -- NvimTree
    "TelescopeNormal",   -- Telescope
    "TelescopeBorder",   -- Telescope borders
    "VertSplit",         -- Vertical split separator
    "StatusLine",        -- Status line
    "StatusLineNC",      -- Inactive status line
    "SignColumn",        -- Sign column
    "LineNr",            -- Line numbers
    "CursorLineNr",      -- Cursor line number
    "Pmenu",             -- Popup menu
    "PmenuSel",          -- Selected item in popup menu
    "FloatBorder",       -- Borders of floating windows
    "WhichKeyFloat",     -- WhichKey floating window
    "NormalNC",          -- Inactive windows
    "MsgArea",           -- Message area
    "EndOfBuffer",       -- End of buffer tildes
  },
  exclude_groups = {},  -- Groups you don't want to clear
})

-- Clear highlights for specific plugins using clear_prefix
local transparent = require("transparent")
transparent.clear_prefix("BufferLine")
transparent.clear_prefix("NeoTree")
transparent.clear_prefix("lualine")
