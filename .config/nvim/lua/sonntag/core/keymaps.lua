local keymap = vim.keymap

vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap.set({"n", "v" }, "<Space>", "<Nop>", { silent = true })

keymap.set("n", "0", "^", { desc = "Goto first non empty character in line" })
keymap.set("n", "<M-down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
keymap.set("n", "<M-o>", "o<ESC>", { desc = "Insert a new line down in normal mode" })
keymap.set("n", "<M-up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap.set("n", "<leader>j", "J", { desc = "Join lines" })
keymap.set("n", "<leader>qq", "<cmd> qa <CR>", { desc = "Close neovim" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
keymap.set("n", "<leader>w", "<cmd> w <CR>", { desc = "Write buffer" })
keymap.set("n", "J", "5j", { desc = "Move 5 lines down" })
keymap.set("n", "K", "5k", { desc = "Move 5 lines up" })
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "<M-k>", ":m '>+1<CR>gv=gv", { desc = "Move line up" })