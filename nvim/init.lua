require('core.options')
require('core.keymaps')

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
   require('plugins.neotree'),
   require('plugins.colorscheme'),
   require('plugins.bufferline'),
   require('plugins.lualine'),
   require('plugins.telescope'),
   require('plugins.treesitter'),
   require('plugins.lsp'),
   require('plugins.autocompletion'),
   require('plugins.gitsigns'),
   require('plugins.alpha'),
   require('plugins.indent-blankline'),
   require('plugins.misc'),
   require('plugins.conform'),
   require('plugins.copilot'),
   require('plugins.oil'),
   require('plugins.slang-server'),
}, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
vim.cmd.colorscheme "catppuccin-macchiato"

local function slang_fuzzy_set_top()
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- 1. Find the Git root
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
        print("Error: Not in a Git repository")
        return
    end

    builtin.find_files({
        results_title = "Select Top Level for Slang",
        cwd = git_root,
        no_ignore = true,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                
                if selection then
                    local full_path
                    -- Check if path is already absolute (starts with /)
                    if selection.path:sub(1, 1) == "/" then
                        full_path = selection.path
                    else
                        full_path = git_root .. "/" .. selection.path
                    end
                    
                    -- Clean up any double slashes (//) just in case
                    full_path = full_path:gsub("//+", "/")
                    
                    -- 3. Execute the Slang command
                    vim.cmd("SlangServer setTopLevel " .. full_path)
                    
                    -- 4. Print the result
                    print(" Slang Top-Level set to: " .. full_path)
                end
            end)
            return true
        end,
    })
end

vim.keymap.set('n', '<leader>st', slang_fuzzy_set_top, { desc = "Fuzzy set Slang Top-Level" })
