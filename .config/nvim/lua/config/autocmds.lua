-- Disable comment continuation on new lines
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("DisableCommentContinuation", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
  end,
})
