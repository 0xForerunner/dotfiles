---@type LazySpec
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<Leader>gg", "<Cmd>Neogit kind=auto<CR>", desc = "Neogit status" },
    },
    opts = {},
  },
}
