local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        { import = 'mp.plugins' },
        { import = 'mp.plugins.lang' },
    },
    dev = {
        path = function(plugin)
            local plugin_directory = '~/dev/'
            if plugin.url:find('andperks', 1, true) == nil then
                plugin_directory = '~/dev/repos/open-source/nvim-plugins/'
            end
            return plugin_directory .. plugin.name
        end,
    },
    change_detection = { notify = false },
})
