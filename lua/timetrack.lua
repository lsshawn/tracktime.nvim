local M = {}

local config = {
	keymap = "<leader>tt",
}

-- In-memory session state
local session = {
	line_number = nil,
	start_time = nil,
	timer_id = nil,
}

local function format_duration(seconds)
	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hours, mins, secs)
end

function M.toggle()
	local line_nr = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()

	-- Resume or pause?
	if session.line_number == line_nr and session.start_time then
		-- PAUSE
		if session.timer_id then
			vim.fn.timer_stop(session.timer_id)
			session.timer_id = nil
			vim.api.nvim_echo({}, false, {}) -- Clear echo message
		end

		local now = os.time()
		local elapsed_sec = now - session.start_time
		if elapsed_sec < 0 then
			elapsed_sec = 0
		end -- handle clock change

		local total_sec = elapsed_sec

		-- Step 1: Find all comments and add their value to total_sec
		local find_pattern = "<!%-%-%s*(-?%d+)%s*(%a+)%s*%-%->"
		for num_str, unit_str in line:gmatch(find_pattern) do
			local val = tonumber(num_str) or 0
			if unit_str == "min" then
				total_sec = total_sec + (val * 60)
			else
				total_sec = total_sec + val
			end
		end

		-- Step 2: Remove all comments from the line
		local remove_pattern = "%s*<!%-%-%s*-?%d+%s*%a+%s*%-%->"
		local cleaned_line = line:gsub(remove_pattern, "")
		cleaned_line = cleaned_line:gsub("%s*$", "")

		if total_sec < 0 then
			total_sec = 0
		end

		-- Always write in seconds for precision
		local updated = cleaned_line .. string.format(" <!-- %d sec -->", total_sec)
		vim.api.nvim_set_current_line(updated)

		local total_min_display = math.floor(total_sec / 60)
		local elapsed_sec_display = elapsed_sec
		print(string.format("⏸️ Paused: +%ds (total: %d min)", elapsed_sec_display, total_min_display))
		session.start_time = nil
		session.line_number = nil
	else
		-- START/RESUME
		if session.timer_id then
			vim.fn.timer_stop(session.timer_id)
			session.timer_id = nil
		end

		session.line_number = line_nr
		session.start_time = os.time()

		local timer_callback = function()
			local elapsed_seconds = os.time() - session.start_time
			local formatted_time = format_duration(elapsed_seconds)
			local msg = { { "▶️ Tracking: " .. formatted_time, "MoreMsg" } }
			vim.schedule(function()
				vim.api.nvim_echo(msg, false, {})
			end)
		end

		session.timer_id = vim.fn.timer_start(1000, timer_callback, { ["repeat"] = -1 })
		timer_callback() -- show immediately
	end
end

local has_setup = false
function M.setup(opts)
	if has_setup then
		return
	end
	has_setup = true

	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	vim.api.nvim_create_user_command("TimeTrackToggle", M.toggle, {
		desc = "Toggle time tracking on the current line",
	})

	if config.keymap then
		vim.keymap.set("n", config.keymap, M.toggle, { desc = "Toggle time tracker" })
	end
end

return M
