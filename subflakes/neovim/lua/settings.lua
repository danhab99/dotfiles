local opt = vim.opt

opt.wildmenu = true
opt.showcmd = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.backspace = { "indent", "eol", "start" }
opt.autoindent = true
opt.ruler = true
opt.confirm = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.expandtab = true
opt.number = true
opt.incsearch = true
opt.smarttab = true
opt.completeopt:remove("preview")
opt.laststatus = 2
opt.belloff = "all"
opt.scrolloff = 15
opt.clipboard:append({ "unnamed", "unnamedplus" })
opt.iskeyword:remove("_")
opt.updatetime = 1000
opt.breakindent = true
opt.smartindent = true
opt.termguicolors = true  
opt.mouse = "a"

-- Disable vim-move default mappings to prevent Esc+j/k issues
vim.g.move_map_keys = 0

-- vim-closetag configuration for HTML/JSX auto-closing
vim.g.closetag_filenames = "*.html,*.xhtml,*.jsx,*.tsx,*.js,*.ts"
vim.g.closetag_xhtml_filenames = "*.xhtml,*.jsx,*.tsx"
vim.g.closetag_filetypes = "html,xhtml,javascript,javascriptreact,typescript,typescriptreact"
vim.g.closetag_xhtml_filetypes = "xhtml,jsx,tsx"
vim.g.closetag_emptyTags_caseSensitive = 1
vim.g.closetag_regions = {
  ["typescript.tsx"] = "jsxRegion,tsxRegion",
  ["javascript.jsx"] = "jsxRegion",
  ["typescriptreact"] = "jsxRegion,tsxRegion", 
  ["javascriptreact"] = "jsxRegion"
}
vim.g.closetag_shortcut = ">"
vim.g.closetag_close_shortcut = "<leader>>"

-- Neoformat configuration for JSX/TSX formatting
vim.g.neoformat_enabled_javascript = {"prettier"}
vim.g.neoformat_enabled_javascriptreact = {"prettier"}
vim.g.neoformat_enabled_typescript = {"prettier"}
vim.g.neoformat_enabled_typescriptreact = {"prettier"}
vim.g.neoformat_enabled_json = {"prettier"}
vim.g.neoformat_enabled_css = {"prettier"}
vim.g.neoformat_enabled_scss = {"prettier"}
vim.g.neoformat_enabled_html = {"prettier"}
vim.g.neoformat_basic_format_align = 1
vim.g.neoformat_basic_format_retab = 1
vim.g.neoformat_basic_format_trim = 1
