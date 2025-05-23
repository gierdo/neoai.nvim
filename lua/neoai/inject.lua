local config = require("neoai.config")
local M = {}

---@type number
M.current_line = nil

---@param txt string
---@param line number
M.append_to_buffer = function(txt, line)
  local cutoff_line_width = config.options.inject.cutoff_width

  local add_lines = function(line, txt)
    vim.api.nvim_buf_set_lines(0, line, line, false, { txt })
  end
  if M.current_line == nil then
    M.current_line = line + 2
    add_lines(line, "")
    add_lines(line + 1, "")
  else
    -- Join all changes into a single undo
    vim.cmd([[undojoin]])
  end

  local lines = vim.split(txt, "\n", {})
  local lines_length = #lines

  for i, line_txt in ipairs(lines) do
    local current_line_txt = vim.api.nvim_buf_get_lines(0, M.current_line - 1, M.current_line, false)[1]

    if cutoff_line_width ~= nil and #current_line_txt >= cutoff_line_width then
      add_lines(M.current_line, line_txt)
      M.current_line = M.current_line + 1
      goto continue
    end

    vim.api.nvim_buf_set_lines(0, M.current_line - 1, M.current_line, false, { current_line_txt .. line_txt })

    if i < lines_length then
      -- Add new line
      add_lines(M.current_line, "")
      M.current_line = M.current_line + 1
    end
    ::continue::
  end
end

return M
