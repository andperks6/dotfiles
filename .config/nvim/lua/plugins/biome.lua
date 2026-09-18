return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
      },
      formatters = {
        biome = {
          require_cwd = true,
          cwd = require("conform.util").root_file({
            "biome.json",
            "biome.jsonc",
          }),
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        javascript = { "biomejs" },
        javascriptreact = { "biomejs" },
        typescript = { "biomejs" },
        typescriptreact = { "biomejs" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "biome" } },
  },
}
