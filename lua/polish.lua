-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

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
