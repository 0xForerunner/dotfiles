return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        -- Remove the specific key binding <Leader>gd
        vim.keymap.del("n", "<Leader>gd", { buffer = bufnr })
      end,
    },
  },
}
