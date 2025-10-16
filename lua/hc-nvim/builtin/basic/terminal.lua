vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(event)
		local id = vim.api.nvim_create_autocmd("BufEnter", {
			buffer = event.buf,
			callback = vim.schedule_wrap(function()
				vim.api.nvim_command("startinsert")
			end),
		})
		vim.api.nvim_create_autocmd("BufDelete", {
			once = true,
			buffer = event.buf,
			callback = function()
				vim.api.nvim_del_autocmd(id)
			end,
		})
	end,
})
