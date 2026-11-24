{ pkgs, zedPkgs }:

{
  # Aparência
  colorize_brackets = true;
  cli_default_open_behavior = "new_window";
  icon_theme = {
    mode = "light";
    light = "Material Icon Theme";
    dark = "Catppuccin Frappé";
  };
  theme = {
    mode = "system";
    light = "One Light";
    dark = "Nordfox - opaque";
  };

  # Tipografia do editor
  buffer_font_family = "CaskaydiaCove Nerd Font";
  buffer_font_fallbacks = [
    "JoySevka Nerd Font"
    "JoySpace Nerd Font"
    "VictorMono Nerd Font"
    "Maple Mono NF"
    "Courier New"
  ];
  buffer_font_size = 16;
  buffer_font_weight = 350;
  buffer_line_height = {
    custom = 1.75;
  };

  # Ligaduras e variantes OpenType
  buffer_font_features = {
    calt = true;
    ss01 = true;
  };

  # Cursor
  cursor_shape = "bar";
  cursor_blink = true;
  cursor_animation = {
    enabled = true;
  };

  # Terminal integrado
  terminal = {
    font_family = "Hack Nerd Font Mono";
    line_height = {
      custom = 1.2;
    };
  };

  # Estilos sintáticos por tema
  theme_overrides = {
    "One Dark" = {
      syntax = {
        comment = {
          font_style = "italic";
        };
        "comment.doc" = {
          font_style = "italic";
        };
        keyword = {
          font_style = "italic";
        };
        type = {
          font_weight = 700;
        };
        "type.builtin" = {
          font_weight = 700;
        };
        "variable.parameter" = {
          font_style = "italic";
        };
      };
    };
  };

  # Tokens semânticos fornecidos pelo LSP
  global_lsp_settings = {
    semantic_token_rules = [
      {
        token_type = "parameter";
        font_style = "italic";
      }
      {
        token_type = "type";
        font_weight = "bold";
      }
      {
        token_type = "interface";
        font_weight = "bold";
      }
      {
        token_type = "typeParameter";
        font_weight = "bold";
      }
    ];
  };

  # Layout e painéis
  outline_panel = {
    dock = "left";
  };
  collaboration_panel = {
    dock = "left";
  };
  git_panel = {
    dock = "left";
  };
  project_panel = {
    dock = "left";
    default_width = 260;
    file_icons = true;
    git_status = true;
    auto_reveal_entries = true;
    show_diagnostics = "all";
  };
  agent = {
    favorite_models = [
      {
        provider = "opencode";
        model = "go/deepseek-v4.1-flash";
        enable_thinking = true;
        effort = "high";
      }
      {
        provider = "opencode";
        model = "go/deepseek-v4-pro";
        enable_thinking = true;
        effort = "high";
      }
      {
        provider = "opencode";
        model = "go/glm-5.3-flash";
        enable_thinking = true;
        effort = "high";
      }
      {
        provider = "mistral";
        model = "mistral-small-latest";
      }
      {
        provider = "copilot_chat";
        model = "gpt-4.1";
      }
    ];
    sandbox_permissions = {
      network_hosts = [
        "raw.githubusercontent.com"
        "duckduckgo.com"
        "html.duckduckgo.com"
        "github.com"
      ];
    };
    default_profile = "ask";
    default_model = {
      provider = "opencode";
      model = "go/deepseek-v4.1-flash";
      enable_thinking = true;
      effort = "high";
    };
    dock = "right";
    threads_sidebar = {
      position = "right";
      auto_open = false;
    };

    commit_message_model = {
      provider = "mistral";
      model = "mistral-small-latest";
    };
    commit_message_instructions = ''
      Use Conventional Commits.
      Write commit messages in English.
      Keep the subject under 72 characters.
      Focus on what changed and why.
      Include a body only when necessary.
    '';

  };
  tab_bar = {
    show = true;
    show_nav_history_buttons = false;
    show_tab_bar_buttons = true;
  };
  tabs = {
    file_icons = true;
    git_status = true;
  };

  # Modelos e agentes de IA
  language_models = {
    opencode = {
      show_zen_models = false;
    };
  };
  agent_servers.claude-acp = {
    default_config_options = {
      mode = "auto";
      agent = "default";
      model = "sonnet";
    };
    favorite_config_option_values = {
      model = [
        "sonnet"
        "opus"
      ];
    };
    type = "registry";
  };

  agent_servers.codex-acp = {
    default_config_options = {
      reasoning_effort = "medium";
    };
    type = "registry";
  };

  agent_servers.github-copilot-cli = {
    default_config_options = {
      model = "mai-code-1.1-flash";
    };
    type = "registry";
  };

  agent_servers."OpenCode ACP" = {
    default_config_options = {
      model = "opencode/deepseek-v4.1-flash-free";
    };
    type = "custom";
    command = "${pkgs.opencode}/bin/opencode";
    args = [
      "acp"
    ];
  };

  agent_servers."Codex (Nix)" = {
    type = "custom";
    command = "${zedPkgs.codex-acp}/bin/codex-acp";
    args = [ ];
  };

  agent_servers."Claude (Nix)" = {
    type = "custom";
    command = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
    args = [ ];
    env = {
      CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";
    };
  };

  # Autocomplete com GitHub Copilot
  show_edit_predictions = true;
  edit_predictions = {
    mode = "subtle";
    provider = "copilot";
    copilot = {
      prediction_debounce = 150;
    };
  };

  # Editor
  base_keymap = "VSCode";
  minimap = {
    show = "always";
  };
  linked_edits = true;
  file_scan_exclusions = [
    "**/obj"
    "..."
  ];
  tab_size = 2;
  format_on_save = "on";

  # Linguagens e formatação
  languages = {
    JavaScript = {
      format_on_save = "on";
      formatter = "auto";
      code_actions_on_format = {
        "source.fixAll.eslint" = true;
      };
    };
    TypeScript = {
      format_on_save = "on";
      formatter = "auto";
      code_actions_on_format = {
        "source.fixAll.eslint" = true;
      };
    };
    TSX = {
      format_on_save = "on";
      formatter = "auto";
      code_actions_on_format = {
        "source.fixAll.eslint" = true;
      };
    };
    Python = {
      format_on_save = "on";
      formatter = {
        language_server = {
          name = "ruff";
        };
      };
      code_actions_on_format = {
        "source.organizeImports.ruff" = true;
      };
    };
    Lua = {
      format_on_save = "on";
      formatter = {
        external = {
          command = "${pkgs.stylua}/bin/stylua";
          arguments = [
            "--syntax=Lua54"
            "--stdin-filepath"
            "{buffer_path}"
            "-"
          ];
        };
      };
    };
    Nix = {
      language_servers = [
        "nixd"
        "!nil"
      ];
      format_on_save = "on";
      formatter = {
        external = {
          command = "${pkgs.nixfmt}/bin/nixfmt";
          arguments = [ ];
        };
      };
    };
  };

  # Servidores de linguagem
  lsp = {
    eslint = {
      settings = {
        workingDirectory = {
          mode = "auto";
        };
      };
    };
    nixd = {
      binary = {
        path = "${pkgs.nixd}/bin/nixd";
      };
    };
  };
  git = {
    enable_status = true;
  };
}
