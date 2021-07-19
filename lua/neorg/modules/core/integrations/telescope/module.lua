--[[
	A Neorg module designed to integrate telescope.nvim
--]]

require('neorg.modules.base')

local module = neorg.modules.create("core.integrations.telescope")

module.load = function()
	local telescope_loaded, telescope = pcall(require, 'telescope')

	assert(telescope_loaded, telescope)

	telescope.load_extension('neorg')
end

return module
