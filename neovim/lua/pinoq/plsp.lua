local csls_ex = require("csharpls_extended")
local mason = require("mason")
local mason_lspcfg = require("mason-lspconfig")
local schemastore = require("schemastore")
local lensline = require("lensline")
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.max_height = 25
    opts.max_width = 75
    -- opts.anchor_bias = "top"
    opts.border = "single"
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local function global_on_attach(client, bufnr)
end

lensline.setup({
    profiles = {
        {
            name = "basic",
            providers = {
                { name = "references", enabled = true, quiet_lsp = true, },
                { name = "last_author", enabled = true, cache_max_files = 100, },
                { name = "diagnostics", enabled = false, },
                { name = "complexity", enabled = false, },
            },
            style = { separator = " • ", highlight = "Comment", prefix = " ", placement = "inline", use_nerdfont = true, render = "all" },
        }
    },
    limits = {
        exclude = {},
        exclude_gitignored = true,
        max_lines = 2000,
        max_lenses = 120,
    },
    debounce_ms = 500,
    focused_debounce_ms = 150,
    debug_mode = false,
})

local lsps = {
    "lua_ls",
    "csharp_ls",
    "bashls",
    "dockerls",
    "yamlls",
    "ruff",
    "pyright",
    "taplo",
    "jsonls",
    "gopls",
    "clangd",
    "jdtls",
    "ts_ls",
    "html",
    "cssls",
    "postgres_lsp",
}

mason.setup()
mason_lspcfg.setup({ automatic_enable = false, ensure_installed = lsps })
vim.lsp.config(
    "lua_ls",
    {
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enabled = false },
                completion = { callSnippet = "Disable" },
            },
        },
    }
)
vim.lsp.config("csharp_ls", {})
vim.lsp.config("bashls", {})
vim.lsp.config("dockerls", {})
vim.lsp.config(
    "yamlls",
    {
        settings = {
            yaml = {
                schemaStore = { enable = false, url = "", },
                schemas = schemastore.yaml.schemas(),
            },
        },
    }
)
vim.lsp.config("ruff", {})
vim.lsp.config(
    "pyright",
    {
        settings = {
            pyright = {
                disableOrganizeImports = true,
                disableTaggedHints = true
            },
            python = {
                analysis = {
                    autoImportCompletions = true,
                    diagnosticMode = "workspace",
                    useLibraryCodeForTypes = true,
                },
            }
        }
    }
)
vim.lsp.config("taplo", {})
vim.lsp.config(
    "jsonls",
    {
        settings = {
            json = {
                schemas = schemastore.json.schemas(),
                validate = { enable = true },
            },
        },
    }
)
vim.lsp.config(
    "gopls",
    {
        settings = {
            gopls = {
                usePlaceholders = false,
            },
        },
    }
)
vim.lsp.config("clangd", {})
vim.lsp.config("jdtls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("html", {})
vim.lsp.config("cssls", {})
vim.lsp.config("postgres_lsp", {})

csls_ex.buf_read_cmd_bind()
vim.lsp.enable(lsps)

vim.keymap.set("n", "<leader>ren", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>doc", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>for", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>sig", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>act", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>res", ":LspRestart<CR>", { silent = true })

-- LazyVim-style LSP keymaps, gated on server capabilities
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end
        local buf = args.buf
        local caps = client.server_capabilities

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        if caps.definitionProvider then
            map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        end
        if caps.referencesProvider then
            map("n", "gr", vim.lsp.buf.references, "References")
        end
        if caps.implementationProvider then
            map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
        end
        if caps.typeDefinitionProvider then
            map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
        end
        if caps.declarationProvider then
            map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        end
        map("n", "K", vim.lsp.buf.hover, "Hover")
        if caps.signatureHelpProvider then
            map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
            map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        end
        if caps.codeActionProvider then
            map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
            map("n", "<leader>cA", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source" }, diagnostics = {} },
                    apply = true,
                })
            end, "Source Action")
            map("n", "<leader>co", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.organizeImports" }, diagnostics = {} },
                    apply = true,
                })
            end, "Organize Imports")
        end
        if caps.codeLensProvider then
            map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
            map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh Codelens")
        end
        if caps.renameProvider then
            map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        end
        if client:supports_method("workspace/willRenameFiles") then
            map("n", "<leader>cR", function()
                require("snacks").rename.rename_file()
            end, "Rename File")
        end
        map("n", "<leader>cl", function()
            require("snacks").picker.lsp_config()
        end, "LSP Info")
    end,
})

vim.diagnostic.config({
    virtual_text = true,
    signs = false,
    underline = false,
    update_in_insert = false,
    severity_sort = false,
})
