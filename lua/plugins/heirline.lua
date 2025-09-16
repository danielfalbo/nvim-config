-- https://github.com/AstroNvim/AstroNvim/blob/2bb2fa9a01311ae7f9bfebf7b3ae996bcc4717be/lua/astronvim/plugins/heirline.lua#L131
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.tabline[2] = status.heirline.make_buflist(status.component.tabline_file_info { close_button = false })
    local tab_section = opts.tabline[#opts.tabline]
    tab_section[#tab_section] = nil

    -- Disable winbar completely
    opts.winbar = nil
  end,
}
