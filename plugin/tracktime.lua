-- Defer setup to allow user configuration to be loaded first
vim.defer_fn(function()
	require("tracktime").setup()
end, 0)
