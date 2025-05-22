local utils = require("neoai.utils")

--- This model definition supports Amazon Q CLI integration
---@type ModelModule
local M = {}

M.name = "Amazon Q"

M._chunks = {}

M.get_current_output = function()
	return table.concat(M._chunks, "")
end

---@param chunk string
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
M._recieve_chunk = function(chunk, on_stdout_chunk)
	-- Split the input chunk by newlines
	on_stdout_chunk(chunk)
	table.insert(M._chunks, chunk)
end

---@param chat_history ChatHistory
---@param on_stdout_chunk fun(chunk: string) Function to call whenever a stdout chunk occurs
---@param on_complete fun(err?: string, output?: string) Function to call when model has finished
M.send_to_model = function(chat_history, on_stdout_chunk, on_complete)
	-- Format messages for Amazon Q CLI
	local messages_json = vim.json.encode(chat_history.messages)

	chunks = {}

	local command = {}
	command = {
		"chat",
		"--no-interactive",
	}
	for _, v in ipairs(chat_history.params) do
		table.insert(command, v)
	end
	table.insert(command, messages_json)

	-- Execute the Amazon Q CLI command
	utils.exec("q", command, function(chunk)
		M._recieve_chunk(chunk, on_stdout_chunk)
	end, function(err, _)
		-- Clean up the temporary file

		on_complete(err, M.get_current_output())
	end)
end

return M
