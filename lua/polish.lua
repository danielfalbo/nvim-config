-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Fix for tree-sitter highlighter "end_col out of range" error
-- Wrap nvim_buf_set_extmark globally to validate column ranges
do
  local original_set_extmark = vim.api.nvim_buf_set_extmark
  vim.api.nvim_buf_set_extmark = function(ns_id, buffer, line, col, opts)
    opts = opts or {}
    col = col or 0
    
    -- Validate column ranges against actual line length
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, buffer, line, line + 1, false)
    if ok and lines[1] then
      local line_len = #lines[1]
      
      -- Clamp end_col to line length
      if opts.end_col and opts.end_col > line_len then
        opts.end_col = line_len
      end
      
      -- Clamp start col to line length
      if col > line_len then
        col = line_len
      end
      
      -- Ensure end_col >= start col
      if opts.end_col and opts.end_col < col then
        opts.end_col = col
      end
    end
    
    return original_set_extmark(ns_id, buffer, line, col, opts)
  end
end

-- Highlight trailing whitespace
vim.api.nvim_set_hl(0, "TrailingWhitespace", { ctermbg = "lightred", bg = "#ff6b6b" })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype
    -- Only highlight in normal file buffers, exclude popups, quickfix, help, etc.
    if buftype == "" and filetype ~= "help" and filetype ~= "qf" then
      vim.cmd([[match TrailingWhitespace /\s\+$/]])
    else
      vim.cmd([[match none]])
    end
  end,
})

-- Set .mdx files to markdown filetype
vim.filetype.add({
  extension = {
    mdx = "markdown",
  },
})

-- Convert double dash to em dash
vim.cmd([[iabbrev -- —]])

-- Custom Zen command with width argument
vim.api.nvim_create_user_command("Zen", function(opts)
  local width = tonumber(opts.args)
  if width then
    -- Store the original width function
    local orig_width = require("snacks").config.zen.win.width
    -- Override with our custom width
    require("snacks").config.zen.win.width = width
    -- Toggle zen mode
    require("snacks").toggle.zen():toggle()
    -- Restore the original width function for next time
    require("snacks").config.zen.win.width = orig_width
  else
    -- If no width specified, just toggle normally
    require("snacks").toggle.zen():toggle()
  end
end, { nargs = "?", desc = "Toggle zen mode with optional width" })

-- Configure completion to trigger on comma for TypeScript imports
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    local cmp_ok, cmp = pcall(require, "cmp")
    if not cmp_ok then return end

    -- Helper function to check if we're inside import braces
    local function is_in_import_braces()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before_cursor = line:sub(1, col)

      -- Match import statements
      if not before_cursor:match("import") then return false end

      -- Find the opening brace
      local import_brace_pos = before_cursor:match("import%s+[^{]*{()")
      if not import_brace_pos then return false end

      -- Count braces from import brace position
      local open_braces = 0
      for i = import_brace_pos, #before_cursor do
        local char = before_cursor:sub(i, i)
        if char == "{" then
          open_braces = open_braces + 1
        elseif char == "}" then
          open_braces = open_braces - 1
          if open_braces == 0 then return false end -- Closed before cursor
        end
      end

      return open_braces > 0
    end

    -- Helper function to trigger completion
    local function trigger_completion()
      -- Use cmp.complete() with a small delay to ensure buffer is updated
      vim.defer_fn(function()
        cmp.complete()
      end, 50)
    end

    -- Use InsertCharPre to catch comma before it's inserted
    -- This is more reliable than overriding keymaps and works with autopairs
    vim.api.nvim_create_autocmd("InsertCharPre", {
      buffer = 0,
      callback = function()
        local char = vim.v.char
        if char == "," then
          -- Check if we're likely in an import before comma is inserted
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local before_cursor = line:sub(1, col)
          local is_import_context = before_cursor:match("import%s+[^{]*{")

          if is_import_context then
            -- Wait for comma to be inserted, then check and trigger
            vim.defer_fn(function()
              if is_in_import_braces() then
                trigger_completion()
              end
            end, 150)
          end
        end
      end,
    })

    -- Also trigger on space after comma
    vim.api.nvim_create_autocmd("InsertCharPre", {
      buffer = 0,
      callback = function()
        local char = vim.v.char
        if char == " " then
          -- Check if we're right after a comma in an import
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local before_cursor = line:sub(1, col)

          if before_cursor:match("import%s+[^{]*{") and before_cursor:match(",%s*$") then
            vim.defer_fn(function()
              if is_in_import_braces() then
                trigger_completion()
              end
            end, 100)
          end
        end
      end,
    })

    -- Manual trigger: <C-Space> to force completion
    vim.keymap.set("i", "<C-Space>", function()
      if is_in_import_braces() then
        trigger_completion()
      else
        -- Fallback to default completion trigger
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-Space>", true, false, true), "n", false)
      end
    end, { buffer = true, desc = "Manual completion trigger in imports" })

    -- Manual trigger: <leader>ci to force import completion
    vim.keymap.set("i", "<leader>ci", function()
      if is_in_import_braces() then
        trigger_completion()
      else
        -- Still trigger even if not detected, might be useful
        trigger_completion()
      end
    end, { buffer = true, desc = "Force import completion" })
  end,
})
