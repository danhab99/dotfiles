local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- File and Window management
map("n", "<C-o>", ":NERDTreeToggle<CR>", opts)
map("n", "<C-u>", ":UndotreeToggle<CR>", opts)
map("n", "<C-f>", ":Neoformat<CR>", opts)
map("i", "<C-f>", "<Esc>:Neoformat<CR>i", opts)
map("n", "O", "O<Esc>o", opts)

-- Escape mappings
map("i", "jj", "<Esc>", opts)
map("i", "kk", "<Esc>", opts)

-- Search and window resize
map("n", "<leader>p", ":psearch <C-R><C-W><CR>", opts)
map("n", "<leader>=", "5<C-w>+", opts)
map("n", "<leader>-", "5<C-w>-", opts)

-- Save + clear highlight
map("n", "<space>", ":noh<CR>:w<CR>", opts)

-- Quick tab + window
map("n", "<C-t>", ":tab sp<CR>", opts)
map("n", "<C-q>", "mq:wqa<CR>", opts)
map("n", "<C-r>", ":source ~/.vimrc<CR>:CocRestart<CR>", opts) -- can be adapted to re-source Lua config

-- Telescope
map("n", "<C-s>", ":FzfLua grep<CR>", opts)

-- Alternate file
map("n", "<C-h>", "<C-^>", opts)

-- Comment + yank helpers
map("n", "yc", "yygccp", opts)

-- Cursor location helpers
map("n", "gg", "mggg", opts)
map("n", "G", "mgG", opts)
map("n", "gm", "<C-w>wj<CR>", opts)
map("n", "i", "mii", opts)
map("n", "I", "miI", opts)
map("n", "a", "mia", opts)
map("n", "A", "miA", opts)
map("n", "o", "mio", opts)
map("n", "gd", "mdgd", opts)
map("n", "gr", "mrgr", opts)
map("n", "ym", "myyy'mp", opts)

-- Go-specific
map("i", "<leader>pe", 'if err != nil { panic (err) }<CR>', opts)
map("n", "<leader>r", ":GoRename<CR>", opts)

-- Mouse toggle
map("n", "<leader>m", ":set mouse=<CR>", opts)
map("n", "<leader>M", ":set mouse=a<CR>", opts)

-- COC specific
map("i", "<C-Space>", 'coc#refresh()', { expr = true, silent = true })
map("i", "<C-@>", 'coc#refresh()', { expr = true, silent = true })
map("i", "<Tab>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], { expr = true, silent = true })
map("n", "gd", "<Plug>(coc-definition)", {})
map("n", "gy", "<Plug>(coc-type-definition)", {})
map("n", "gi", "<Plug>(coc-implementation)", {})
map("n", "gr", "<Plug>(coc-references)", {})
map("n", "<leader>h", ":call CocActionAsync('doHover')<CR>", opts)
map("n", "<leader>d", ":CocDiagnostic<CR>", opts)

-- Titlecase plugin
map("n", "<leader>gt", "<Plug>Titlecase", {})
map("v", "<leader>gt", "<Plug>Titlecase", {})
map("n", "<leader>gT", "<Plug>TitlecaseLine", {})

-- Tagbar
map("n", "<leader>t", ":TagbarToggle<CR>", opts)
