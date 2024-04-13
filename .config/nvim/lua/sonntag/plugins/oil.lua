return {
	-- 'stevearc/oil.nvim',
	dir = '~/Dropbox/Development/sonntag/oil.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('oil').setup()
		vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
	end,
}
