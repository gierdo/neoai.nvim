local utils = require("neoai.utils")

--- This model definition supports Amazon Q CLI integration
---@type ModelModule
local M = {}

M.name = "Amazon Q"

M._chunks = {}
local raw_chunks = {}

M.get_current_output = function()
	return table.concat(M._chunks, "")
end

local function remove_ansi_escape_codes(str)
	return str:gsub("\27%[[%d;]*[mK]", "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._recieve_chunk = function(chunk, on_stdout_chunk)
	-- Split the input chunk by newlines
	local cleaned_chunk = remove_ansi_escape_codes(chunk)
	on_stdout_chunk(cleaned_chunk)
	table.insert(M._chunks, cleaned_chunk)
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function(chat_history, on_stdout_chunk, on_complete)
	-- Format messages for Amazon Q CLI
	local messages_json = vim.json.encode(chat_history.messages)

	-- Build the command to execute
	local command = string.format("q chat --no-interactive '%s'", messages_json)

	-- Add model parameters if available
	if chat_history.params then
		-- Convert params to CLI arguments if needed
		-- This would need to be adapted based on Amazon Q CLI's parameter format
	end

	chunks = {}
	raw_chunks = {}

	-- Execute the Amazon Q CLI command
	utils.exec("bash", {
		"-c",
		command,
	}, function(chunk)
		M._recieve_chunk(chunk, on_stdout_chunk)
	end, function(err, _)
		-- Clean up the temporary file

		on_complete(err, M.get_current_output())
	end)
end

return M
