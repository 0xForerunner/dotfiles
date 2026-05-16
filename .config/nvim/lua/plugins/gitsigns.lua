---@type LazySpec
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts = opts or {}
      local on_attach = opts.on_attach

      opts.on_attach = function(bufnr)
        if on_attach then on_attach(bufnr) end

        -- AstroNvim maps this buffer-locally to gitsigns.diffthis(), which
        -- shadows the global Diffview mapping in Git buffers.
        pcall(vim.keymap.del, "n", "<Leader>gd", { buffer = bufnr })
      end

      return opts
    end,
  },
}
