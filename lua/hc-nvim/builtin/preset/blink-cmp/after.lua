return function()
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	-- set to static config
	vim.lsp.config("*", { capabilities = capabilities })
	-- apply on active client
	for _, client in ipairs(vim.lsp.get_clients()) do
		client.capabilities = capabilities
		client.server_capabilities.completionProvider = false
	end
end
