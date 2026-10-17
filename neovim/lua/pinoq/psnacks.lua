local snacks = require("snacks")

-- Only enable what we need; leave the rest of snacks disabled so it does not
-- fight with the mini.nvim / indent-blankline UI already configured here.
snacks.setup({
    explorer = {},
    -- keep the target's mini.pick as `vim.ui.select`
    picker = { ui_select = false },
    bufdelete = {},
    rename = {},
    toggle = {},
})

local function root()
    local ok, r = pcall(snacks.git.get_root)
    if ok and r then
        return r
    end
    return vim.uv.cwd() or vim.fn.getcwd()
end

local function map(lhs, rhs, desc, mode)
    vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = desc })
end

-- Files / pickers / explorer
map("<leader><space>", function() snacks.picker.files({ cwd = root() }) end, "Find Files (Root Dir)")
map("<leader>,", function() snacks.picker.buffers() end, "Buffers")
map("<leader>/", function() snacks.picker.grep({ cwd = root() }) end, "Grep (Root Dir)")
map("<leader>:", function() snacks.picker.command_history() end, "Command History")

map("<leader>ff", function() snacks.picker.files({ cwd = root() }) end, "Find Files (Root Dir)")
map("<leader>fF", function() snacks.picker.files() end, "Find Files (cwd)")
map("<leader>fg", function() snacks.picker.git_files() end, "Find Files (git-files)")
map("<leader>fb", function() snacks.picker.buffers() end, "Buffers")
map("<leader>fB", function() snacks.picker.buffers({ hidden = true, nofile = true }) end, "Buffers (all)")
map("<leader>fc", function() snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "Find Config File")
map("<leader>fr", function() snacks.picker.recent() end, "Recent")
map("<leader>fR", function() snacks.picker.recent({ filter = { cwd = true } }) end, "Recent (cwd)")
map("<leader>fn", "<cmd>enew<cr>", "New File")

map("<leader>fe", function() snacks.explorer({ cwd = root() }) end, "Explorer (Root Dir)")
map("<leader>fE", function() snacks.explorer() end, "Explorer (cwd)")
map("<leader>e", function() snacks.explorer({ cwd = root() }) end, "Explorer (Root Dir)")
map("<leader>E", function() snacks.explorer() end, "Explorer (cwd)")

-- Buffers
map("[b", "<cmd>bprevious<cr>", "Prev Buffer")
map("]b", "<cmd>bnext<cr>", "Next Buffer")
map("<leader>bb", "<cmd>e #<cr>", "Switch to Other Buffer")
map("<leader>bd", function() snacks.bufdelete() end, "Delete Buffer")
map("<leader>bo", function() snacks.bufdelete.other() end, "Delete Other Buffers")
map("<leader>bi", function() snacks.bufdelete.invisible() end, "Delete Invisible Buffers")
map("<leader>bD", "<cmd>bd<cr>", "Delete Buffer and Window")

-- UI toggles
snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
snacks.toggle.diagnostics():map("<leader>ud")
snacks.toggle.line_number():map("<leader>ul")
snacks.toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal Level" }):map("<leader>uc")
snacks.toggle.option("showtabline", { off = 0, on = 2, name = "Tabline" }):map("<leader>uA")
snacks.toggle.treesitter():map("<leader>uT")
snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
snacks.toggle.inlay_hints():map("<leader>uh")

-- Animate (mini.animate)
map("<leader>ua", function()
    local ok = pcall(function() MiniAnimate.toggle() end)
    if not ok then
        vim.notify("MiniAnimate is not available", vim.log.levels.WARN)
    end
end, "Toggle Animate")

-- Indent guides (indent-blankline)
map("<leader>ug", function()
    local ok = pcall(vim.cmd, "IBLToggle")
    if not ok then
        vim.notify("indent-blankline is not available", vim.log.levels.WARN)
    end
end, "Toggle Indent Guides")

-- Inspect
map("<leader>ui", vim.show_pos, "Inspect Pos")
map("<leader>uI", function()
    vim.treesitter.inspect_tree()
    vim.api.nvim_input("I")
end, "Inspect Tree")
