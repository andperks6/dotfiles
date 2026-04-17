-- Use tsgo (native TypeScript LSP) instead of vtsls
-- Based on LazyVim's upcoming tsgo extra
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/typescript/tsgo.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable vtsls and ts_ls
        vtsls = { enabled = false },
        ts_ls = { enabled = false },
        tsserver = { enabled = false },
        -- Enable tsgo
        tsgo = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = {
                  enabled = "literals",
                  suppressWhenArgumentMatchesName = true,
                },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
}
