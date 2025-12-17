{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig = {
    enable = true;
  };
  programs = {
    atuin.enable = true;
    bash = {
      enable = true;
      initExtra = ''
        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }
      '';
    };
    fish = {
      enable = true;
      functions = {
        y = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };
    };
    fzf.enable = true;
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "tokyonight";

        editor = {
          line-number = "relative";
          mouse = true;
        };
        
        editor.lsp = {
          display-messages = true;
        };
        
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        
        editor.soft-wrap = {
          enable = true;
        };
      };
    };
    micro = {
      enable = true;
    };
    nixvim = {
      enable = true;
      # enableMan = false;
      # defaultEditor = true;
      waylandSupport = true;
      # Tree-sitter dependencies for :TSInstallFromGrammar
      extraPackages = with pkgs; [
        tree-sitter  # Tree-sitter parser generator
        nodejs      # Node.js for tree-sitter grammar compilation
      ];
      opts = {
        # Tab and indentation settings
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        smartindent = true;
        autoindent = true;
        # Line numbers
        number = true;
        relativenumber = true;
        # Other useful settings
        wrap = false;
        cursorline = true;
        # Timeout settings for better plugin compatibility
        timeoutlen = 1000;
        updatetime = 300;
      };
      plugins = {
        avante = {
          enable = true;
          settings = {
            provider = "openrouter";
            auto_suggestions_provider = "openrouter";
            providers = {
              copilot = {
                __raw = ''
                  {
                    parse_curl_args = function() return {} end,
                    parse_response_data = function() return "" end,
                    list_models = function() return {} end,
                  }
                '';
              };
              openrouter = {
                __inherited_from = "openai";
                api_key_name = "OPENROUTER_API_KEY";
                endpoint = "https://openrouter.ai/api/v1";
                model = "anthropic/claude-sonnet-4.5";
                timeout = 30000;
                model_names = [
                  # Anthropic Claude 
                  "anthropic/claude-sonnet-4.5"    
                  "anthropic/claude-haiku-4.5"     
                  "anthropic/claude-opus-4.1"      

                  # OpenAI
                  "openai/gpt-4.1"                 
                  "openai/gpt-4o"                  
                  "openai/gpt-4o-mini"             

                  # Google Gemini
                  "google/gemini-2.5-pro"          
                  "google/gemini-2.5-flash"        
                  "google/gemini-2.5-pro-exp-03-25:free" 

                  # DeepSeek 
                  "deepseek/deepseek-r1"           
                  "deepseek/deepseek-r1:free"      

                  # Meta Llama 
                  "meta-llama/llama-4-maverick:free"      
                  "meta-llama/llama-3.3-70b-instruct:free"
                ];
                extra_request_body = {
                  temperature = 0;
                  max_tokens = 4096;
                };
              };
            };
          };
        };
        codecompanion = {
          enable = true;
          settings = {
            # Configure adapters using the new http structure
            adapters = {
              http = {
                anthropic = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("anthropic", {
                        env = {
                          api_key = "ANTHROPIC_API_KEY",
                        },
                      })
                    end
                  '';
                };
                openai = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("openai", {
                        env = {
                          api_key = "OPENAI_API_KEY",
                        },
                      })
                    end
                  '';
                };
                openrouter = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("openai", {
                        env = {
                          api_key = "OPENROUTER_API_KEY",
                        },
                        url = "https://openrouter.ai/api/v1/chat/completions",
                        schema = {
                          model = {
                            default = "anthropic/claude-3.5-sonnet",
                          },
                        },
                      })
                    end
                  '';
                };
              };
            };
            # Set strategies to use specific adapters
            strategies = {
              chat = {
                adapter = "anthropic";
              };
              inline = {
                adapter = "anthropic";
              };
            };
            # Enable debug logging and other options
            opts = {
              log_level = "DEBUG";
              send_code = true;
              use_default_actions = true;
              use_default_prompts = true;
            };
            # Configure display settings for better autocomplete
            display = {
              action_palette = {
                provider = "default";
                opts = {
                  show_default_prompt_library = true;
                };
              };
              chat = {
                window = {
                  layout = "vertical";
                  opts = {
                    breakindent = true;
                  };
                };
              };
            };
          };
        };
        orgmode = {
          enable = true;
          settings = {
            org_agenda_files = [ "~/org/*.org" ];
            org_default_notes_file = "~/org/notes.org";
            org_todo_keywords = [ "TODO" "DOING" "|" "DONE" ];
          };
        };
        which-key.enable = true;
        telescope.enable = true;
        treesitter = {
          enable = true;
          settings = { 
            indent.enable = true;
            ensure_installed = [ "lua" "nix" "python" "json" "yaml" "markdown" "bash" "javascript" "html" "css" ];
          };
        };
        treesitter-textobjects.enable = true;
        lsp = {
          enable = true;
          servers = {
            lua_ls.enable = true;
            pyright.enable = true;
            jsonls.enable = true;
            nil_ls.enable = true;
            bashls.enable = true;
            ts_ls.enable = true;
          };
        };
        # Enable nvim-cmp for CodeCompanion autocomplete
        cmp = {
          enable = true;
          settings = {
            completion = {
              completeopt = "menu,menuone,noinsert";
            };
            preselect = "None";
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
            mapping = {
              __raw = ''
                {
                  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = cmp.mapping.confirm({ select = true }),
                  ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip and luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip and luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<Down>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      fallback()
                    end
                  end, { 'i', 's', 'c' }),
                  ['<Up>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    else
                      fallback()
                    end
                  end, { 'i', 's', 'c' }),
                }
              '';
            };
          };
        };
        luasnip.enable = true;
        comment.enable = true;
        nvim-autopairs.enable = true;
        nvim-surround.enable = true;
        # indent-blankline.enable = true;
        gitsigns.enable = true;
        diffview = {
          enable = true;
          settings = {
            # Remove hg_cmd since it's not available and not needed
            # hg_cmd = "hg";  # Commented out to avoid warning
          };
        };
        lualine.enable = true;
        bufferline.enable = true;
        colorizer.enable = true;
        dressing.enable = true;
        oil.enable = true;
        flash.enable = true;
        visual-multi.enable = true;
        web-devicons.enable = true;
        yanky.enable = true;
      };
    };
    nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
    };
    ranger.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zellij = {
      enable = true;
      settings = {
        # theme = "dracula";
      };
    };
  };
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # AI Tools
    aichat
    claude-code
  
    # mullvad-vpn
    axel
    btop
    duf
    fastfetch
    fd
    gh
    kitty
    # moc
    nerd-fonts.jetbrains-mono
    nix-search
    ripgrep
    tldr
    topgrade
    warp
            
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/fortydeux/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  targets.genericLinux.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
