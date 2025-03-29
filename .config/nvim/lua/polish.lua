-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
-- vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
-- vim.o.shiftwidth = 4 -- An autoindent will use 4 spaces

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.conceallevel = 2 end,
})

-- disable default mappings
vim.api.nvim_set_keymap("n", "<leader>o", "", { noremap = true, silent = true })
