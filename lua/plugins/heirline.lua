return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    local heirline = require "heirline"
    local conditions = require "heirline.conditions"

    -- Helper function to get colors from theme highlight groups
    local function get_hl_color(name, attr)
      attr = attr or "fg"
      -- Map fg/bg to foreground/background
      local mapped_attr = (attr == "fg" and "foreground") or (attr == "bg" and "background") or attr
      local hl = vim.api.nvim_get_hl_by_name(name, true)
      if hl and hl[mapped_attr] then
        return string.format("#%06x", hl[mapped_attr])
      end
      return nil
    end

    -- Function to update User highlight groups with theme colors
    local function update_user_highlights()
      -- Get background from StatusLine or Normal
      local bg = get_hl_color("StatusLine", "bg") or get_hl_color("Normal", "bg") or "#000000"

      -- Get foreground colors from semantic highlight groups
      -- User1 (green) - use String, DiffAdd, or SuccessMsg
      local green = get_hl_color("String") or get_hl_color("DiffAdd") or get_hl_color("SuccessMsg") or "#00ff00"

      -- User2 (yellow) - use Number, WarningMsg, or Todo
      local yellow = get_hl_color("Number") or get_hl_color("WarningMsg") or get_hl_color("Todo") or "#ffff00"

      -- User3 (red) - use Error, ErrorMsg, or DiffDelete
      local red = get_hl_color("Error") or get_hl_color("ErrorMsg") or get_hl_color("DiffDelete") or "#ff0000"

      -- User4 (blue) - use Function, Type, or Identifier
      local blue = get_hl_color("Function") or get_hl_color("Type") or get_hl_color("Identifier") or "#0000ff"

      -- User5 (white/neutral) - use Normal foreground or Comment
      local white = get_hl_color("Normal") or get_hl_color("Comment") or "#ffffff"

      -- Set highlight groups
      vim.api.nvim_set_hl(0, "User1", { fg = green, bg = bg })
      vim.api.nvim_set_hl(0, "User2", { fg = yellow, bg = bg })
      vim.api.nvim_set_hl(0, "User3", { fg = red, bg = bg })
      vim.api.nvim_set_hl(0, "User4", { fg = blue, bg = bg })
      vim.api.nvim_set_hl(0, "User5", { fg = white, bg = bg })
    end

    -- Update highlights initially
    update_user_highlights()

    -- Update highlights when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_user_highlights,
    })

    -- Custom statusline components
    local file_format = {
      provider = function()
        return " " .. vim.bo.fileformat
      end,
      hl = "User5",
    }

    local file_type = {
      provider = function()
        local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "no ft"
        return "[" .. ft .. "]"
      end,
      hl = "User3",
    }

    local file_path = {
      provider = function()
        local path = vim.fn.expand "%:."
        return " " .. path .. " "
      end,
      hl = "User4",
    }

    local modified_flag = {
      provider = function()
        return vim.bo.modified and "%m" or ""
      end,
      hl = "User2",
    }

    local current_line = {
      provider = function()
        return vim.api.nvim_win_get_cursor(0)[1]
      end,
      hl = "User1",
    }

    local total_lines = {
      provider = function()
        return "/" .. vim.api.nvim_buf_line_count(0)
      end,
      hl = "User2",
    }

    local virtual_column = {
      provider = function()
        local col = vim.fn.virtcol "."
        return " " .. col .. " "
      end,
      hl = "User1",
    }

    local char_under_cursor = {
      provider = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
        local char = line_content:sub(col + 1, col + 1)
        if char == "" then return "0x0000 " end
        local byte = string.byte(char)
        return string.format("0x%04X ", byte)
      end,
      hl = "User2",
    }

    -- Build the statusline matching the original format
    local statusline = {
      file_format,
      file_type,
      file_path,
      modified_flag,
      { provider = "%=", hl = "User1" }, -- separator (pushes right side to the right)
      current_line,
      total_lines,
      virtual_column,
      char_under_cursor,
    }

    -- Replace default statusline
    opts.statusline = statusline

    -- Keep tabline modifications
    opts.tabline[2] = status.heirline.make_buflist(status.component.tabline_file_info { close_button = false })
    local tab_section = opts.tabline[#opts.tabline]
    tab_section[#tab_section] = nil

    -- Disable winbar completely
    opts.winbar = nil
  end,
}
