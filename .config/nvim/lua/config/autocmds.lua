-- Fix ENOENT crash in LazyVim root detector (nvim 0.12 + vim.fs.find strictness)
local root = require("lazyvim.util.root")
local orig_pattern = root.detectors.pattern
root.detectors.pattern = function(buf, patterns)
  local ok, result = pcall(orig_pattern, buf, patterns)
  if ok then
    return result
  end
  return {}
end

-- Disable comment continuation on new lines
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("DisableCommentContinuation", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
  end,
})
