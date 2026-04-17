return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>o", function() require("oil").toggle_float() end, desc = "Oil (floating)" },
  },
  opts = {
    keymaps = {
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-x>"] = "actions.select_split",
      ["<C-h>"] = false,
      ["<C-l>"] = false,
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name)
        return name == ".DS_Store" or name == ".git"
      end,
    },
    float = { padding = 10 },
  },
}
