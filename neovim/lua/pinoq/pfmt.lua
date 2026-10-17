local conform = require("conform")
local lint = require("lint")

-- Auto format on save (on by default, toggleable per buffer / globally)
local autoformat_global = true
local autoformat_buf = {}

local function autoformat_enabled(bufnr)
    local enabled = autoformat_buf[bufnr]
    if enabled == nil then
        enabled = autoformat_global
    end
    return enabled
end

conform.setup({
    formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        go = { "gofumpt" },
        cs = { "csharpier" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        java = { "google-java-format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        sh = { "shfmt" },
        lua = { "stylua" },
        sql = { "sqlfluff" },
        mysql = { "sqlfluff" },
        plsql = { "sqlfluff" },
    },
    formatters = {
        sqlfluff = {
            args = { "format", "--dialect=postgres", "-" },
        },
    },
    format_on_save = function(bufnr)
        if not autoformat_enabled(bufnr) then
            return nil
        end
        return { timeout_ms = 500, lsp_format = "never" }
    end,
})

-- SQL linting via sqlfluff (PostgreSQL dialect)
for _, ft in ipairs({ "sql", "mysql", "plsql" }) do
    lint.linters_by_ft[ft] = lint.linters_by_ft[ft] or {}
    table.insert(lint.linters_by_ft[ft], "sqlfluff")
end
lint.linters.sqlfluff = {
    args = { "lint", "--format=json", "--dialect=postgres", "-" },
}
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
    conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })

vim.keymap.set("n", "<leader>uf", function()
    local bufnr = vim.api.nvim_get_current_buf()
    autoformat_buf[bufnr] = not autoformat_enabled(bufnr)
    vim.notify("Format on save (buffer): " .. (autoformat_buf[bufnr] and "on" or "off"))
end, { desc = "Toggle Auto Format (buffer)" })

vim.keymap.set("n", "<leader>uF", function()
    autoformat_global = not autoformat_global
    vim.notify("Format on save (global): " .. (autoformat_global and "on" or "off"))
end, { desc = "Toggle Auto Format (global)" })

-- Install the formatter tools through mason
local formatter_tools = {
    "ruff",
    "gofumpt",
    "csharpier",
    "clang-format",
    "google-java-format",
    "prettier",
    "shfmt",
    "stylua",
    "sqlfluff",
}
local ok, registry = pcall(require, "mason-registry")
if ok then
    registry.refresh(function()
        for _, tool in ipairs(formatter_tools) do
            local found, package = pcall(registry.get_package, tool)
            if found and not package:is_installed() then
                package:install()
            end
        end
    end)
end
