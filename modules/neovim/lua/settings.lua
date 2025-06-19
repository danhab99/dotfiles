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
