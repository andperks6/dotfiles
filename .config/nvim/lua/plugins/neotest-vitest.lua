return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "marilari88/neotest-vitest",
  },
  opts = {
    adapters = {
      ["neotest-vitest"] = {},
    },
  },
}
