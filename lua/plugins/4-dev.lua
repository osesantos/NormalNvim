-- Dev
-- Things you actively use for coding.

--    Sections:
--       ## COMMENTS
--       -> comment.nvim                   [adv. comments]

--       ## SNIPPETS
--       -> luasnip                        [snippet engine]
--       -> friendly-snippets              [snippet templates]

--       ## GIT
--       -> gitsigns.nvim                  [git hunks]
--       -> fugitive.vim                   [git commands]

--       ## DEBUGGER
--       -> nvim-dap                       [debugger]

--       ## TESTING
--       -> neotest.nvim                   [unit testing]

--       ## ANALYZER
--       -> aerial.nvim                    [code analyzer]

--       ## CODE DOCUMENTATION
--       -> vim-doxigen                    [general    doc generator]
--       -> vim-typedoc                    [typescript doc generator]

--       ## EXTRA
--       -> guess-indent                   [guess-indent]
--       -> neural                         [chatgpt code generator]
--       -> markdown-preview.nvim          [markdown previewer]
--       -> markmap                        [markdown mindmap]

--       ## NOT INSTALLED
--       -> distant.nvim                   [ssh to edit in a remove machine]

return {
  --  COMMENTS ----------------------------------------------------------------
  --  Advanced comment features [adv. comments]
  --  https://github.com/numToStr/Comment.nvim
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring =
          pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail
          and commentstring
          and { pre_hook = commentstring.create_pre_hook() }
          or {}
    end,
  },

  --  SNIPPETS ----------------------------------------------------------------
  --  Vim Snippets engine  [snippet engine] + [snippet templates]
  --  https://github.com/L3MON4D3/LuaSnip
  --  https://github.com/rafamadriz/friendly-snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function(_, opts)
      if opts then require("luasnip").config.setup(opts) end
      vim.tbl_map(
        function(type) require("luasnip.loaders.from_" .. type).lazy_load() end,
        { "vscode", "snipmate", "lua" }
      )
    end,
  },

  --  GIT ---------------------------------------------------------------------
  --  Git signs [git hunks]
  --  https://github.com/lewis6991/gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    event = "User BaseGitFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "󰐊" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  --  Git fugitive mergetool + [git commands]
  --  https://github.com/lewis6991/gitsigns.nvim
  {
    "https://github.com/tpope/vim-fugitive",
    enabled = vim.fn.executable "git" == 1,
    cmd = {
      "Gvdiffsplit",
      "Gdiffsplit",
      "Gedit",
      "Gsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GRename",
      "GDelete",
      "GRemove",
      "GBrowse",
      "Git",
      "Gstatus",
    },
    event = "User BaseGitFile",
    init = function() vim.g.fugitive_no_maps = 1 end,
  },

  --  DEBUGGER ----------------------------------------------------------------
  --  Debugger alternative to vim-inspector [debugger]
  --  https://github.com/mfussenegger/nvim-dap
  {
    "mfussenegger/nvim-dap",
    enabled = vim.fn.has "win32" == 0,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "nvim-dap" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = { handlers = {} },
      },
      {
        "rcarriga/nvim-dap-ui",
        opts = { floating = { border = "rounded" } },
        config = function(_, opts)
          local dap, dapui = require "dap", require "dapui"
          dap.listeners.after.event_initialized["dapui_config"] = function(
          )
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function(
          )
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
          dapui.setup(opts)
        end,
      },
    },
    event = "User BaseFile",
  },

  --  TESTING ----------------------------------------------------------------
  --  Run tests inside of nvim [unit testing]
  --  https://github.com/nvim-neotest/neotest
  --
  --
  --  MANUAL:
  --  -- Unit testing:
  --  To tun an unit test you can run any of these commands:
  --
  --    :TestRunBlock   -- Runs the nearest test to the cursor.
  --    :TestStopBlock  -- Stop the nearest test to the cursor.
  --    :TestRunFile    -- Run all tests in the file.
  --    :TestDebugBlock -- Debug the nearest test under the cursor using dap
  --
  --  All this commands are meant to be executed in a test file.
  --  You can find them on ../base/3-autocmds.lua
  --
  --  -- E2e and Test Suite
  --  Normally you will prefer to open your e2e framework GUI outside of nvim.
  --  But you have the next commands in ../base/3-autocmds.lua:
  --
  --    :TestNodejs    -- Run all tests for this nodejs project.
  --    :TestNodejsE2e -- Run the e2e tests/suite for this nodejs project.
  {
    "nvim-neotest/neotest",
    cmd = {             -- All this commands are meant to run in a test file
      "TestRunBlock",   -- Run the nearest test to the cursor.
      "TestStopBlock",  -- Stop the test to the cursor.
      "TestDebugBlock", -- Debug the nearest test under the cursor using dap.
      "TestRunFile",    -- Run all tests in the file.
    },
    config = function()
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace "neotest"
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message
                :gsub("\n", " ")
                :gsub("\t", " ")
                :gsub("%s+", " ")
                :gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)
      require("neotest").setup {
        -- your neotest config here
        adapters = {
          require "neotest-dotnet",
          require "neotest-python",
          require "neotest-rust",
          require "neotest-go",
          require "neotest-jest",
          require "neotest-minitest",
          require "neotest-rspec",
          require "neotest-vitest",
          require "neotest-testthat",
          require "neotest-phpunit",
          require "neotest-pest",
        },
      }
    end,
    dependencies = {
      "Issafalcon/neotest-dotnet",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
      "olimorris/neotest-rspec",
      "marilari88/neotest-vitest",
      "shunsambongi/neotest-testthat",
      "olimorris/neotest-phpunit",
      "theutz/neotest-pest",
    },
  },

  --  Shows a float panel with the [code coverage]
  --  https://github.com/andythigpen/nvim-coverage
  {
    "andythigpen/nvim-coverage",
    cmd = {
      "Coverage",
      "CoverageLoad",
      "CoverageLoadLcov",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageClear",
      "CoverageSummary",
    },
    requires = { "nvim-lua/plenary.nvim" },
  },

  --  ANALYZER ----------------------------------------------------------------
  --  [code analyzer]
  --  https://github.com/stevearc/aerial.nvim
  {
    "stevearc/aerial.nvim",
    event = "User BaseFile",
    cmd = {
      "AerialToggle",
      "AerialOpen",
      "AerialNavOpen",
      "AerialInfo",
      "AerialClose",
    },
    opts = {
      open_automatic = false, -- Open if the buffer is compatible
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { min_width = 28 },
      show_guides = true,
      filter_kind = false,
      guides = {
        mid_item = "├ ",
        last_item = "└ ",
        nested_top = "│ ",
        whitespace = "  ",
      },
      keymaps = {
        ["[y"] = "actions.prev",
        ["]y"] = "actions.next",
        ["[Y"] = "actions.prev_up",
        ["]Y"] = "actions.next_up",
        ["{"] = false,
        ["}"] = false,
        ["[["] = false,
        ["]]"] = false,
      },
    },
  },
  -- Telescope integration (:Telescope aerial)
  {
    "nvim-telescope/telescope.nvim",
    opts = function() require("telescope").load_extension "aerial" end,
  },

  --  CODE DOCUMENTATION ----------------------------------------------------------------
  --  vim-doxygen
  --  https://github.com/Zeioth/vim-doxygen
  {
    "Zeioth/vim-doxygen",
    tf = {
      "c",
      "cpp",
      "cs",
      "python",
      "d",
      "fortran",
      "java",
      "perl",
      "vhdl",
      "objc",
      "php",
    },
    cmd = {
      "TypedocOpen",
      "TypedocRegen",
    },
  },
  --  vim-typedoc
  --  https://github.com/Zeioth/vim-typedoc
  {
    "Zeioth/vim-doxygen",
    tf = { "typescript" },
    cmd = {
      "DoxygenOpen",
      "DoxygenRegen",
    },
  },

  --  EXTRA ----------------------------------------------------------------
  --  [guess-indent]
  --  https://github.com/NMAC427/guess-indent.nvim
  {
    "NMAC427/guess-indent.nvim",
    event = "User BaseFile",
    config = function(_, opts)
      require("guess-indent").setup(opts)
      vim.cmd.lua {
        args = { "require('guess-indent').set_from_buffer('auto_cmd')" },
        mods = { silent = true },
      }
    end,
  },

  --  neural [chatgpt code generator]
  --  https://github.com/dense-analysis/neural
  {
    "dense-analysis/neural",
    cmd = { "Neural" },
    config = function()
      require("neural").setup {
        source = {
          openai = {
            api_key = vim.env.OPENAI_API_KEY,
          },
        },
        ui = {
          prompt_icon = ">",
        },
      }
    end,
  },

  --  [markdown previewer]
  --  https://github.com/iamcco/markdown-preview.nvim
  --  Note: If you change the build command, wipe ~/.local/data/nvim/lazy
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    cmd = {
      "MarkdownPreview",
      "MarkdownPreviewStop",
      "MarkdownPreviewToggle",
    },
    build = "cd app && npm install",
  },
}
