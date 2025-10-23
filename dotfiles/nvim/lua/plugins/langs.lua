return {
  -- nvim treesitter to manage treesitter (native lang parsing)
  -- also provides lang-informed syntax coloring
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      -- A list of parser names, or "all" (the listed parsers MUST be installed)
      ensure_installed = { "go", "lua", "javascript", "jsx", "python", "html", "java", "fsharp" },
      
      -- Install parsers synchronously (only applied to 'ensure_installed')
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      -- ( disabled because this might be causing that they don't get installed at all? )
      -- ( I installed with sudo apt install tree-sitter-cli )
      auto_install = false,

      -- List of parsers to ignore installing (or "all")
      -- Don't fully see the point in this, I'll leave the array empty
      ignore_install = {},

      ---- If you need to change the installation directory of the parsers (see -> advanced setup on repo)
      -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

      highlight = {
        enable = true,

        -- NOTE these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of languages that will be disabled
        disable = {},

        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        -- disable = function(lang, buf)
        --    local max_filesize = 100 * 1024 -- 100 KB
        --    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        --    if ok and stats and stats.size > max_filesize then
        --        return true
        --    end
        -- end,
        
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on `syntax` being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local vtext = function(client, bufnr)
        vim.diagnostic.config({ virtual_text = true })
      end

      vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
        callback = function(args)
          if vim.bo[args.buf].filetype ~= "" then
            vim.cmd("TSBufEnable highlight")
          end
        end,
      })

      -- Set up go
      vim.lsp.enable('gopls')
      vim.lsp.config('gopls', {
        on_attach = vtext,
      })

      vim.lsp.enable('ts_ls')
      vim.lsp.config('ts_ls', {
        capabilities = caps,
        on_attach = vtext,
      })

      vim.lsp.enable('pyright')
      vim.lsp.config('pyright', {
        capabilities = caps,
        on_attach = vtext,
      })

      vim.lsp.enable('harper_ls')
      vim.lsp.config('harper_ls', {
        capabilities = caps,
        on_attach = vtext,
        filetypes = { "markdown", "text", "plaintext" },
      })

      vim.lsp.enable('emmet_ls')
      vim.lsp.config('emmet_ls', {
        capabilities = caps,
        on_attach = vtext,
        filetypes = { "html", "css", "ejs" },
        init_options = {
          html = {
            options = {
              ["bem.enabled"] = true,
            }
          }
        }
      })

      vim.lsp.enable('nil_ls')
      vim.lsp.config('nil_ls', {
        capabilities = caps,
        on_attach = vtext,
        filetypes = { "nix" },
      })

      local function root_pattern(...)
        local patterns = { ... }

        return function(startpath)
          local path = startpath or vim.api.nvim_buf_get_name(0)
          if path == "" then
            path = vim.loop.cwd()
          end

          -- Use vim.fs.find(Neovim 8.0+), searching upward
          local found = vim.fs.find(patterns, { path = path, upward = true })
          if #found > 0 then
            return vim.fs.dirname(found[1])
          end
          return nil
        end
      end

      vim.lsp.enable('fsautocomplete')
      vim.lsp.config('fsautocomplete', {
        capabilities = caps,
        on_attach = vtext,
        filetypes = { "fsharp" },
      })

      vim.lsp.enable('omnisharp')
      vim.lsp.config('omnisharp', {
        cmd = { "OmniSharp", "-z", "--hostPID", tostring(vim.fn.getpid()), "Dotnet:enablePackageRestore=false", "--encoding", "utf-8", "--languageserver" },
        capabilities = caps,
        on_attach = vtext,
        filetypes = { "cs", "vb" },
      })

    end,
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt", "gomodifytags", "impl", "delve", "pyright", "jdtls" }},
  },
  {
    "fredrikaverpil/neotest-golang",
  },
  {
    "echasnovski/mini.icons",
    opts = {
      file = {
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
      },
      filetype = {
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
  },
  { "hrsh7th/cmp-nvim-lsp" }, { "hrsh7th/cmp-buffer" }, { "hrsh7th/cmp-path" }, { "hrsh7th/cmp-cmdline" }, { 'saadparwaiz1/cmp_luasnip' }, { 'L3MON4D3/LuaSnip' },
  {
    "hrsh7th/nvim-cmp",
    main = "cmp",
    opts = function(_, opts)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      opts.snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      }
      opts.mapping = {
        ['<C-Space>'] = cmp.mapping.complete(),           -- trigger autocompletion
        ['<CR>'] = cmp.mapping.confirm({ select = true}), -- confirm completion
        ['<Tab>'] = cmp.mapping.select_next_item(),       -- select next item
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),     -- select previous item
        ['<C-e>'] = cmp.mapping.close(),                  -- close the completion menu
      }
      opts.sources = {
        { name = 'nvim_lsp' },  -- LSP completions
        { name = 'luasnip' },   -- Snippets completions
        { name = 'buffer' },    -- Buffer completions (useful for open files)
        { name = 'path' },      -- Path completions
      }
      opts.formatting = {
        format = function(entry, vim_item)
          vim_item.kind = string.format('%s', vim_item.kind)
          return vim_item
        end,
      }
    end,
    dependencies = {'cmp_luasnip'},
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {disable_mouse = false},
  },
}
