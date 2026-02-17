-- WPM Mode Signal Plugin
-- Writes current Neovim mode to $XDG_RUNTIME_DIR/wpm-nvim-mode
-- so that wpm-monitor can suppress normal-mode navigation keystrokes.

return {
	{
		name = "wpm-mode",
		dir = vim.fn.stdpath("config"),
		lazy = false,
		config = function()
			local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
			local mode_file = runtime_dir .. "/wpm-nvim-mode"

			local typing_modes = {
				i = true,
				ic = true,
				ix = true,
				R = true,
				Rc = true,
				Rv = true,
				Rvc = true,
				Rvx = true,
			}

			local function write_mode(mode_str)
				local f = io.open(mode_file, "w")
				if f then
					f:write(mode_str)
					f:close()
				end
			end

			local function update_mode()
				local mode = vim.api.nvim_get_mode().mode
				if typing_modes[mode] then
					write_mode("insert")
				else
					write_mode("normal")
				end
			end

			-- Write initial mode on startup
			write_mode("normal")

			vim.api.nvim_create_autocmd("ModeChanged", {
				pattern = "*",
				callback = update_mode,
			})

			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					os.remove(mode_file)
				end,
			})
		end,
	},
}
