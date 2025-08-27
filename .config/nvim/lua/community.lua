-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- { import = "astrocommunity.pack.cpp" },
  -- { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.helm" },
  -- { import = "astrocommunity.pack.ansible" },

  -- { import = "astrocommunity.recipes.heirline-vscode-winbar" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.scrolling.neoscroll-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  -- { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.search.grug-far-nvim" },
}
