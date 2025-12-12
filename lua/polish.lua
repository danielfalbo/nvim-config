-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Force truecolor support (fixes tmux color issues)
vim.opt.termguicolors = true

-- Use separate lines for status bar and command bar (like vanilla vim)
vim.opt.cmdheight = 1

-- Set terminal title to current filename
vim.opt.title = true

-- Update terminal title when switching buffers
local function update_title()
  local buftype = vim.bo.buftype
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Only update for real file buffers
  if buftype ~= "" and buftype ~= "acwrite" then return end

  -- Skip buffers with special names (like filetype-match-scratch)
  if bufname ~= "" and (bufname:match "filetype%-" or bufname:match "^[^/]*%-scratch") then return end

  local filename = ""
  if bufname ~= "" then
    filename = vim.fn.fnamemodify(bufname, ":t")
  else
    filename = "[No Name]"
  end

  -- Try to find project root (git repository)
  local project_name = ""
  if bufname ~= "" then
    local file_dir = vim.fn.fnamemodify(bufname, ":p:h")
    -- Use git rev-parse to get the root directory (more reliable)
    local git_root_output = vim.fn.systemlist("cd " .. vim.fn.shellescape(file_dir) .. " && git rev-parse --show-toplevel 2>/dev/null")
    if git_root_output and #git_root_output > 0 and git_root_output[1] ~= "" then
      local root_dir = git_root_output[1]
      project_name = vim.fn.fnamemodify(root_dir, ":t")
    end
  end

  -- Build title: project name + filename, or just filename
  local title = filename
  if project_name ~= "" then
    title = project_name .. " - " .. filename
  end

  if filename ~= "" then vim.opt.titlestring = title end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "BufWritePost" }, {
  pattern = "*",
  callback = update_title,
})
-- Force truecolor even when TERM doesn't advertise it (common in tmux)
if vim.env.TMUX then
  -- Override TERM to signal truecolor support
  vim.env.TERM = "tmux-256color"
  vim.env.COLORTERM = "truecolor"
  -- Force Neovim to use truecolor regardless of terminfo
  vim.cmd "set termguicolors"
end

-- Enable system clipboard on Linux
if vim.fn.has "unix" == 1 and vim.fn.has "mac" == 0 and vim.fn.has "macunix" == 0 then
  vim.opt.clipboard = "unnamedplus"
end

-- Fix for tree-sitter highlighter "end_col out of range" error
-- Wrap nvim_buf_set_extmark globally to validate column ranges
do
  local original_set_extmark = vim.api.nvim_buf_set_extmark
  vim.api.nvim_buf_set_extmark = function(ns_id, buffer, line, col, opts)
    opts = opts or {}
    col = col or 0

    -- Validate buffer exists and is valid
    if not vim.api.nvim_buf_is_valid(buffer) then return original_set_extmark(ns_id, buffer, line, col, opts) end

    -- Validate line is within buffer range
    local line_count = vim.api.nvim_buf_line_count(buffer)
    if line < 0 or line >= line_count then return original_set_extmark(ns_id, buffer, line, col, opts) end

    -- Validate column ranges against actual line length
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, buffer, line, line + 1, false)
    if ok and lines[1] then
      local line_len = #lines[1]

      -- Clamp start col to line length (0-indexed, so max is line_len)
      if col < 0 then col = 0 end
      if col > line_len then col = line_len end

      -- Clamp end_col to line length and ensure it's >= start col
      if opts.end_col then
        if opts.end_col < 0 then opts.end_col = 0 end
        if opts.end_col > line_len then opts.end_col = line_len end
        if opts.end_col < col then opts.end_col = col end
      end
    else
      -- If we can't get the line, skip end_col to avoid errors
      opts.end_col = nil
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
    local bufname = vim.api.nvim_buf_get_name(0)
    local modifiable = vim.bo.modifiable
    local buflisted = vim.bo.buflisted
    local is_regular_buffer = buftype == "" and filetype ~= "help" and filetype ~= "qf"
    local is_named_buffer = is_regular_buffer and bufname ~= ""
    local is_new_buffer = is_regular_buffer and bufname == "" and modifiable and buflisted
    -- Only highlight in normal file buffers
    -- Exclude popups, quickfix, help, dashboard, etc.
    -- Dashboard buffers are typically unnamed, so require bufname OR (unnamed + modifiable + listed for new files)
    local is_normal_file = is_named_buffer or is_new_buffer -- Allow unnamed new files if they're modifiable and listed
    if is_normal_file then
      vim.cmd [[match TrailingWhitespace /\s\+$/]]
    else
      vim.cmd [[match none]]
    end
  end,
})

-- Set .mdx files to markdown filetype
vim.filetype.add {
  extension = {
    mdx = "markdown",
  },
}

-- -- Convert double dash to em dash
-- vim.cmd [[iabbrev -- —]]

-- Disable cursorline (ensure it stays off)
vim.opt.cursorline = false
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "VimEnter" }, {
  pattern = "*",
  callback = function() vim.opt.cursorline = false end,
})

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

-- Close quickfix buffer after jumping to location with <cr>
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<cr>", function()
      vim.cmd "cc"
      vim.cmd "cclose"
    end, { buffer = true, desc = "Jump to location and close quickfix" })
  end,
})

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
      if not before_cursor:match "import" then return false end

      -- Find the opening brace
      local import_brace_pos = before_cursor:match "import%s+[^{]*{()"
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
      vim.defer_fn(function() cmp.complete() end, 50)
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
          local is_import_context = before_cursor:match "import%s+[^{]*{"

          if is_import_context then
            -- Wait for comma to be inserted, then check and trigger
            vim.defer_fn(function()
              if is_in_import_braces() then trigger_completion() end
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

          if before_cursor:match "import%s+[^{]*{" and before_cursor:match ",%s*$" then
            vim.defer_fn(function()
              if is_in_import_braces() then trigger_completion() end
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

-- read .vimrc.local if present (relative to current working dir)
if vim.fn.filereadable ".vimrc.local" == 1 then vim.cmd "source .vimrc.local" end

-- macOS system appearance detection and colorscheme switching
if vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1 then
  local function get_system_appearance()
    local handle = io.popen "defaults read -g AppleInterfaceStyle 2>/dev/null"
    if handle then
      local result = handle:read "*a"
      handle:close()
      return result:match "Dark" and "dark" or "light"
    end
    return "dark" -- default to dark if detection fails
  end

  local function set_colorscheme_from_system()
    local appearance = get_system_appearance()
    local colorscheme = appearance == "light" and "dawnfox" or "nordfox"
    pcall(vim.cmd, "colorscheme " .. colorscheme)
  end

  -- Set colorscheme on startup
  set_colorscheme_from_system()

  -- Check for system appearance changes periodically (every 5 seconds)
  local timer = vim.loop.new_timer()
  local last_appearance = get_system_appearance()
  timer:start(5000, 5000, function()
    local current_appearance = get_system_appearance()
    if current_appearance ~= last_appearance then
      last_appearance = current_appearance
      vim.schedule(set_colorscheme_from_system)
    end
  end)

  -- Command to manually refresh colorscheme
  vim.api.nvim_create_user_command("RefreshColorscheme", set_colorscheme_from_system, {
    desc = "Refresh colorscheme based on macOS system appearance",
  })
end
