vim.opt.swapfile = false -- no more .swp files

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.conceallevel = 2 end,
})

-- allows 'words' to contain dashes
vim.opt.iskeyword:append "-"

vim.keymap.set("n", "<leader>fw", function() require("snacks").picker.grep { hidden = true, ignored = true } end, {
  desc = "Find words in all files",
})

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
