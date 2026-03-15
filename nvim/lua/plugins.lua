return {
  -- Colorscheme
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme("dracula") end,
  },

  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "go", "gomod", "gosum",
        "python",
        "hcl", "terraform",
        "yaml", "json", "toml",
        "dockerfile",
        "bash",
        "lua",
        "helm",
        "markdown",
        "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    ft = { "go", "python", "terraform", "yaml", "json", "helm", "lua" },
    config = function()
      local lsp = require("lspconfig")
      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then caps = cmp_lsp.default_capabilities(caps) end

      local servers = {
        gopls = {},
        pyright = {},
        terraformls = {},
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                kubernetes = "/*.yaml",
              },
              validate = true,
              completion = true,
            },
          },
        },
        helm_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = { checkThirdParty = false },
            },
          },
        },
      }

      for server, opts in pairs(servers) do
        opts.capabilities = caps
        lsp[server].setup(opts)
      end

      -- LSP keymaps (on attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local buf = ev.buf
          local m = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end
          m("n", "gd", vim.lsp.buf.definition)
          m("n", "gr", vim.lsp.buf.references)
          m("n", "K", vim.lsp.buf.hover)
          m("n", "<leader>rn", vim.lsp.buf.rename)
          m("n", "<leader>ca", vim.lsp.buf.code_action)
          m("n", "[d", vim.diagnostic.goto_prev)
          m("n", "]d", vim.diagnostic.goto_next)
        end,
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "path" } },
          { { name = "buffer" } }
        ),
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
      })
    end,
  },
}
