local mn_starter = require('mini.starter')
local mn_pick = require("mini.pick")

local win_config = function()
    local height = math.floor(0.618 * vim.o.lines)
    local width = math.floor(0.618 * vim.o.columns)
    return {
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
    }
end
mn_pick.setup({
    delay = { async = 10, busy = 50, },
    mappings = {
        caret_left        = "",
        caret_right       = "",
        choose            = "<CR>",
        choose_in_split   = "<C-x>",
        choose_in_tabpage = "<C-t>",
        choose_in_vsplit  = "<C-v>",
        delete_char       = "<BS>",
        move_down         = "<Tab>",
        move_up           = "<S-Tab>",
        refine            = "<C-r>",
        stop              = "<Esc>",
        toggle_preview    = "<C-p>",
        scroll_down       = "<C-d>",
        scroll_left       = "",
        scroll_right      = "",
        scroll_up         = "<C-u>",
        choose_marked     = "",
        delete_char_right = "",
        delete_left       = "",
        delete_word       = "",
        mark              = "",
        mark_all          = "",
        move_start        = "",
        paste             = "",
        refine_marked     = "",
        toggle_info       = "",
    },
    source = {
        items = nil,
        name = nil,
        cwd = nil,
        match = nil,
        show = nil,
        preview = nil,
        choose = nil,
        choose_marked = nil,
    },
    options = { content_from_bottom = false, use_cache = false, },
    window = { config = win_config, prompt_caret = "█", prompt_prefix = ": ", },
})
mn_starter.setup({
    autoopen = true,
    evaluate_single = false,
    items = {
        {
            { name = "Blank",   action = "enew",       section = "Actions" },
            { name = "Explore", action = "Pick files", section = "Actions" },
            { name = "Quit",    action = "q",          section = "Actions" },
        }
    },
    header = [[
      nvim
    ]],
    footer = "",
    content_hooks = nil,
    query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.",
    silent = true,
})


vim.keymap.set("n", "<leader>rsm", ":Pick resume<CR>", { silent = true })
vim.keymap.set("n", "<leader>gre", ":Pick grep_live<CR>", { silent = true })
vim.keymap.set("n", "<leader>fnd", ":Pick files<CR>", { silent = true })
vim.keymap.set("n", "<leader>dia", ":Pick diagnostic<CR>", { silent = true })
vim.keymap.set("n", "<leader>def", ":Pick lsp scope='definition'<CR>", { silent = true })
vim.keymap.set("n", "<leader>dec", ":Pick lsp scope='declaration'<CR>", { silent = true })
vim.keymap.set("n", "<leader>buf", ":Pick buffers<CR>", { silent = true })
vim.keymap.set("n", "<leader>tdf", ":Pick lsp scope='type_definition'<CR>", { silent = true })
vim.keymap.set("n", "<leader>imp", ":Pick lsp scope='implementation'<CR>", { silent = true })
vim.keymap.set("n", "<leader>ref", ":Pick lsp scope='references'<CR>", { silent = true })
vim.keymap.set("n", "<leader>dym", ":Pick lsp scope='document_symbol'<CR>", { silent = true })
vim.keymap.set("n", "<leader>wym", ":Pick lsp scope='workspace_symbol'<CR>", { silent = true })
vim.keymap.set("n", "<leader>kmp", ":Pick keymaps<CR>", { silent = true })
vim.keymap.set("n", "<leader>cmt", ":Pick git_commits<CR>", { silent = true })
vim.keymap.set("n", "<leader>brn", ":Pick git_branches<CR>", { silent = true })
vim.keymap.set("n", "<leader>exp", ":Pick explorer<CR>", { silent = true })
vim.keymap.set("n", "<Up>", ":resize -1<CR>", { silent = true })
vim.keymap.set("n", "<Down>", ":resize +1<CR>", { silent = true })
vim.keymap.set("n", "<Left>", ":vertical resize -1<CR>", { silent = true })
vim.keymap.set("n", "<Right>", ":vertical resize +1<CR>", { silent = true })
vim.keymap.set("n", "<leader>hls", ":set hlsearch!<CR>", { silent = true })
vim.keymap.set("n", "H", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "L", ":bnext<CR>", { silent = true })

vim.ui.select = mn_pick.ui_select
