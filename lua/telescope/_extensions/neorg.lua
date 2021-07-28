return require('telescope').register_extension {
	exports = {
		find_linkable = require('neorg.modules.core.integrations.telescope.module').public.find_linkable,
		insert_link = require('neorg.modules.core.integrations.telescope.module').public.insert_link,
	}
}
