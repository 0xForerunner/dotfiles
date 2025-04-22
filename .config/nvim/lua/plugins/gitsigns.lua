return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr) vim.keymap.del("n", "<Leader>gd", { buffer = bufnr }) end,
    },
  },
}
