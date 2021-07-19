return require('telescope').register_extension {
	exports = {
		find_headings = require('telescope._extensions.neorg.find_headings')
	}
}
