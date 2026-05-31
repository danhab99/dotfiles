-- lua/plugins/transparent.lua
local M = {}

M.clear_backgrounds = function()
  local hl = vim.api.nvim_set_hl
  local groups = {
    "Normal", "NormalNC", "SignColumn", "LineNr", "CursorLineNr",
    "NonText", "EndOfBuffer", "FoldColumn",

    -- Gutter plugins
    "GitSignsAdd", "GitSignsChange", "GitSignsDelete",
    "GitGutterAdd", "GitGutterChange", "GitGutterDelete",

    -- Telescope
    "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
    "TelescopeResultsNormal", "TelescopePromptBorder", "TelescopeResultsBorder",

    -- Floating
    "NormalFloat", "FloatBorder", "Pmenu",
    "SpellBad", "DiagnosticVirtualTextError", "DiagnosticVirtualTextWarn",
  }

  for _, group in ipairs(groups) do
    hl(0, group, { bg = "none", ctermbg = "none" })
  end
end

return M
