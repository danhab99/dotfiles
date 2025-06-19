-- lua/plugins/ui.lua

local opt = vim.opt
local cmd = vim.cmd
local g = vim.g

-- Basic UI Options
opt.number = true
opt.relativenumber = false
opt.cursorline = false
opt.scrolloff = 15
opt.termguicolors = true
-- opt.background = "dark"
opt.showcmd = true
opt.wildmenu = true
opt.ruler = true
opt.laststatus = 2
opt.confirm = true
opt.belloff = "all"
opt.updatetime = 1000

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.breakindent = true

-- Search behavior
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Backspace behavior
opt.backspace = { "indent", "eol", "start" }

-- Completion behavior
opt.completeopt:remove("preview")

-- Clipboard integration
opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Keywords
opt.iskeyword:remove("_")

-- Colorscheme
-- g.onedark_termcolors = 256
-- cmd("colorscheme onedark")
require('onedark').setup  {
    -- Main options --
    style = 'dark', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = true,  -- Show/hide background
    term_colors = true, -- Change terminal color as per the selected theme style
    ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
    cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

    -- toggle theme style ---
    toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
    -- toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between
    toggle_style_list = {'dark'}, 

    -- Change code style ---
    -- Options are italic, bold, underline, none
    -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
    code_style = {
        comments = 'italic',
        keywords = 'none',
        functions = 'none',
        strings = 'none',
        variables = 'none'
    },

    -- Lualine options --
    lualine = {
        transparent = false, -- lualine center bar transparency
    },

    -- Custom Highlights --
    colors = {}, -- Override default colors
    highlights = {
        -- For gitsigns.nvim
      GitSignsAdd    = { bg = "none" },
      GitSignsChange = { bg = "none" },
      GitSignsDelete = { bg = "none" },

      -- For vim-gitgutter
      GitGutterAdd    = { bg = "none" },
      GitGutterChange = { bg = "none" },
      GitGutterDelete = { bg = "none" },

      -- Line number and sign column
      SignColumn      = { bg = "none" },
      LineNr          = { bg = "none" },
      CursorLineNr    = { bg = "none" },

      -- Optional: Telescope transparency
      TelescopeNormal = { bg = "none" },
      TelescopeBorder = { bg = "none" },
      TelescopePromptNormal = { bg = "none" },
      TelescopeResultsNormal = { bg = "none" },  
    },

    -- Plugins Config --
    diagnostics = {
        darker = true, -- darker colors for diagnostic
        undercurl = true,   -- use undercurl instead of underline for diagnostics
        background = false,    -- use background color for virtual text
    },
}
require('onedark').load()

-- vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "BufWinEnter", "CursorMoved", "UIEnter", "UILeave", "DiffUpdated" }, {
--   -- pattern = "*",
--   callback = function()
--     local clear_bg = {
--       -- GitGutter (vim-gitgutter)
--       "GitGutterAdd",
--       "GitGutterChange",
--       "GitGutterDelete",
--       -- GitSigns (if you ever use it)
--       "GitSignsAdd",
--       "GitSignsChange",
--       "GitSignsDelete",
--       -- Sign column and line numbers
--       "SignColumn",
--       "LineNr",
--       "CursorLineNr",
--     }

--     for _, group in ipairs(clear_bg) do
--       vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
--     end
--   end,
-- })
