return {
	'folke/noice.nvim',
	dependencies = {
		'MunifTanjim/nui.nvim',
	},
	event = 'VeryLazy',
	enabled = false,
	opts = {
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				['vim.lsp.util.convert_input_to_markdown_lines'] = true,
				['vim.lsp.util.stylize_markdown'] = true,
				['cmp.entry.get_documentation'] = false, -- requires hrsh7th/nvim-cmp
			},
		},
		presets = {
			bottom_search = false, -- don't use classic bottom cmdline search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-renam.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	},
}
