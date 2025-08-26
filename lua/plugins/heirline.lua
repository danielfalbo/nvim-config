-- The only diff from this and AstroNvim default is that this hides the close_button
-- TODO: this should just be an astroui option

return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    return require("astrocore").extend_tbl(opts, {
      tabline = {
        {  -- automatic sidebar padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            self.winwidth = vim.api.nvim_win_get_width(self.winid)
            return self.winwidth ~= vim.o.columns
              and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid))
          end,
          provider = function(self) return (" "):rep(self.winwidth + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info({
          close_button = false,
        })),
      },
    })
  end,
}
