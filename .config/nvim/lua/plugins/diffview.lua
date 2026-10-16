local diff_context = 24

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "dlyongemallo/diffview.nvim",
    event = "User AstroGitFile",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    init = function()
      local diffopt = vim.tbl_filter(function(value) return not value:match "^context:" end, vim.opt.diffopt:get())
      table.insert(diffopt, ("context:%d"):format(diff_context))
      vim.opt.diffopt = diffopt
    end,
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      },
      hooks = { diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = false end },
    },
    specs = {
      {
        "NeogitOrg/neogit",
        optional = true,
        opts = { integrations = { diffview = true } },
      },
    },
  },
}
