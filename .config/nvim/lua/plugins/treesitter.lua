-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "markdown",
      "markdown_inline",
      "starlark",
      "solidity",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
