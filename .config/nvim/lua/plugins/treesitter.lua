-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "jsonc",
      "lua",
      "vim",
      "markdown",
      "markdown_inline",
      "regex",
      "starlark",
      "solidity",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
