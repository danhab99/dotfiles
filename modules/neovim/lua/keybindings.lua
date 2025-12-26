-- Keymap helper
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Plugins
map("n", "<C-o>", ":NERDTreeToggle<CR>", opts)
map("n", "<C-u>", ":UndotreeToggle<CR>", opts)
map("n", "<C-f>", ":Neoformat<CR>", opts)
map("i", "<C-f>", "<Esc>:Neoformat<CR>i", opts)

-- Editing
map("n", "O", "O<Esc>o", opts)
map("i", "jj", "<Esc>", opts)
map("i", "kk", "<Esc>", opts)

-- Search
map("n", "<leader>p", ":psearch <C-R><C-W><CR>", opts)
map("n", "<space>", ":noh<CR>:w<CR>", opts)

-- Window resizing
map("n", "<leader>=", "5<C-w>+", opts)
map("n", "<leader>-", "5<C-w>-", opts)
-- map("n", "<S-[>", ':exe "resize " . (winheight(0) * 3/2)<CR>', opts)
-- map("n", "<S-]>", ':exe "resize " . (winheight(0) * 2/3)<CR>', opts)

-- Misc
map("n", "-a", ":call SyntaxAttr()<CR>", opts)
map("n", "<C-t>", ":tab sp<CR>", opts)
map("n", "<C-q>", "mq:wqa<CR>", opts)
map("n", "<C-r>", ":source ~/.vimrc<CR>:CocRestart<CR>", opts)
map("n", "<C-s>", ":FzfLua grep<CR>", opts)
map("n", "<C-h>", "<C-^>", opts)

-- Yank / move
vim.keymap.set("n", "yc", function()
  vim.cmd("normal! yy")
  vim.cmd("normal gcc")
  vim.cmd("normal! p")
end, opts)
map("n", "gg", "mggg", opts)
map("n", "G", "mgG", opts)
map("n", "gm", "<C-w>wj<CR>", opts)

-- Save cursor positions with marks
map("n", "i", "mii", opts)
map("n", "I", "miI", opts)
map("n", "a", "mia", opts)
map("n", "A", "miA", opts)
map("n", "o", "mio", opts)
map("n", "gd", "mdgd", opts)
map("n", "gr", "mrgr", opts)
map("n", "ym", "myyy'mp", opts)

-- Go-specific
map("i", "<leader>pe", "if err != nil { panic (err) }<CR>", opts)

-- Mouse toggle
map("n", "<leader>m", ":set mouse=<CR>", opts)
map("n", "<leader>M", ":set mouse=a<CR>", opts)

-- === COC.nvim ===
map("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })
map("i", "<c-@>", "coc#refresh()", { silent = true, expr = true })
map("i", "<TAB>",
    'coc#pum#visible() ? coc#pum#confirm() : "\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>"',
    { silent = true, expr = true })

map("n", "gd", "<Plug>(coc-definition)", { silent = true })
map("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
map("n", "gi", "<Plug>(coc-implementation)", { silent = true })
map("n", "gr", "<Plug>(coc-references)", { silent = true })
map("n", "<leader>h", ":call CocActionAsync('doHover')<CR>", { silent = true })

-- Titlecase plugin
map("n", "<leader>gt", "<Plug>Titlecase", {})
map("v", "<leader>gt", "<Plug>Titlecase", {})
map("n", "<leader>gT", "<Plug>TitlecaseLine", {})

-- Tagbar
map("n", "<leader>t", ":TagbarToggle<CR>", opts)

-- Diagnostics
map("n", "<leader>d", ":CocDiagnostic<CR>", opts)

-- Go rename
map("n", "<leader>r", ":GoRename<CR>", opts)

map("i", "<leader>c", ":CopilotChatToggle<CR>", opts) 
map("n", "<leader>c", ":CopilotChatToggle<CR>", opts) 
