return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = {}, -- disabled formatting for markdown
      ["markdown.mdx"] = {}, -- disabled formatting for mdx
      graphql = { "prettier" },
      handlebars = { "prettier" },
    },
    -- Use format_after_save for non-blocking format on save
    format_after_save = true,
    -- Still keep a timeout for safety
    timeout_ms = 3000,
    -- Fall back to LSP formatting
    lsp_fallback = true,
  },
}
