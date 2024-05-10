-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = true },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },

  -- {
  --   "andythigpen/nvim-coverage",
  --   lazy = false,
  --   requires = "nvim-lua/plenary.nvim",
  --   config = function()
  --     require("coverage").setup {
  --       commands = true, -- create commands
  --       highlights = {
  --         -- customize highlight groups created by the plugin
  --         covered = { fg = "#75e36b" }, -- supports style, fg, bg, sp (see :h highlight-gui)
  --         uncovered = { fg = "#F07178" },
  --       },
  --       signs = {
  --         -- use your own highlight groups or text markers
  --         covered = { hl = "CoverageCovered", text = "▎" },
  --         uncovered = { hl = "CoverageUncovered", text = "▎" },
  --       },
  --       summary = {
  --         -- customize the summary pop-up
  --         min_coverage = 80.0, -- minimum coverage threshold (used for highlighting)
  --       },
  --       lang = {
  --         -- customize language specific settings
  --       },
  --     }
  --   end,
  -- },
  -- This generates the winbar
  -- {
  --   "rebelot/heirline.nvim",
  --   opts = function(_, opts)
  --     local status = require "astronvim.utils.status"
  --
  --     opts.winbar = { -- create custom winbar
  --       -- store the current buffer number
  --       init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
  --       fallthrough = false, -- pick the correct winbar based on condition
  --       -- inactive winbar
  --       {
  --         condition = function() return not status.condition.is_active() end,
  --         -- show the path to the file relative to the working directory
  --         status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } },
  --         -- add the file name and icon
  --         status.component.file_info {
  --           file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
  --           file_modified = false,
  --           file_read_only = false,
  --           hl = status.hl.get_attributes("winbarnc", true),
  --           surround = false,
  --           update = "BufEnter",
  --         },
  --       },
  --       -- active winbar
  --       {
  --         -- show the path to the file relative to the working directory
  --         status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } },
  --         -- add the file name and icon
  --         status.component.file_info { -- add file_info to breadcrumbs
  --           file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
  --           file_modified = false,
  --           file_read_only = false,
  --           hl = status.hl.get_attributes("winbar", true),
  --           surround = false,
  --           update = "BufEnter",
  --         },
  --         -- show the breadcrumbs
  --         status.component.breadcrumbs {
  --           icon = { hl = true },
  --           hl = status.hl.get_attributes("winbar", true),
  --           prefix = true,
  --           padding = { left = 0 },
  --         },
  --       },
  --     }
  --
  --     return opts
  --   end,
  -- },
}
