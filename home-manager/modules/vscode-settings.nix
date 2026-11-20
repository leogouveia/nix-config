{
  userSettings = {
    "editor.fontFamily" = "'FiraCode Nerd Font', 'Fira Code', Consolas, 'Courier New', monospace";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 16;
    "editor.inlineSuggest.enabled" = true;
    "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
    "terminal.integrated.fontFamily" = "'Hack Nerd Font'";
    "terminal.integrated.fontSize" = 16;
    "window.menuBarVisibility" = "visible";
    "window.titleBarStyle" = "custom";
    "files.exclude" = {
      "**/bin" = false;
      "**/obj" = true;
    };
    "security.workspace.trust.untrustedFiles" = "open";
    "settingsSync.ignoredExtensions" = [
      "ms-vscode.cpptools"
    ];
    "editor.formatOnSave" = true;
    "javascript.updateImportsOnFileMove.enabled" = "always";
    "eslint.validate" = [
      "javascript"
      "javascriptreact"
      "astro"
    ];
    "typescript.autoClosingTags" = false;
    "[vue]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[html]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[javascriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[json]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[c]" = {
      "editor.defaultFormatter" = "ms-vscode.cpptools";
    };
    "[mdx]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.formatOnSave" = false;
    };
    "workbench.colorCustomizations" = {
      "[Material Theme Darker High Contrast]" = {
        "activityBarBadge.background" = "#80CBC4";
        "activityBar.activeBorder" = "#80CBC4";
        "list.activeSelectionForeground" = "#80CBC4";
        "list.inactiveSelectionForeground" = "#80CBC4";
        "list.highlightForeground" = "#80CBC4";
        "scrollbarSlider.activeBackground" = "#80CBC450";
        "editorSuggestWidget.highlightForeground" = "#80CBC4";
        "textLink.foreground" = "#80CBC4";
        "progressBar.background" = "#80CBC4";
        "pickerGroup.foreground" = "#80CBC4";
        "tab.activeBorder" = "#80CBC4";
        "notificationLink.foreground" = "#80CBC4";
        "editorWidget.resizeBorder" = "#80CBC4";
        "editorWidget.border" = "#80CBC4";
        "settings.modifiedItemIndicator" = "#80CBC4";
        "settings.headerForeground" = "#80CBC4";
        "panelTitle.activeBorder" = "#80CBC4";
        "breadcrumb.activeSelectionForeground" = "#80CBC4";
        "menu.selectionForeground" = "#80CBC4";
        "menubar.selectionForeground" = "#80CBC4";
        "editor.findMatchBorder" = "#80CBC4";
        "selection.background" = "#80CBC440";
        "statusBarItem.remoteBackground" = "#80CBC4";
      };
      "terminal.background" = "#00000000";
      "editorPane.background" = "#1e1e1e00";
      "editorGroupHeader.tabsBackground" = "#1e1e1e00";
      "editorGroupHeader.noTabsBackground" = "#1e1e1e00";
      "breadcrumb.background" = "#1e1e1e00";
      "editorGutter.background" = "#1e1e1e00";
      "panel.background" = "#1e1e1e00";
      "tab.activeBackground" = "#1e1e1e00";
      "tab.unfocusedActiveBackground" = "#1e1e1e00";
      "sideBar.background" = "#1e1e1ecc";
      "sideBarTitle.background" = "#1e1e1ecc";
      "activityBar.background" = "#1e1e1ecc";
      "editor.background" = "#1e1e1ecc";
      "tab.inactiveBackground" = "#1e1e1ecc";
      "tab.unfocusedInactiveBackground" = "#1e1e1ecc";
      "editorStickyScroll.background" = "#1e1e1ecc";
      "editorStickyScrollGutter.background" = "#1e1e1ecc";
      "sideBarStickyScroll.background" = "#1e1e1ecc";
      "panelStickyScroll.background" = "#1e1e1ecc";
      "terminalStickyScroll.background" = "#1e1e1ecc";
      "minimap.background" = "#1e1e1ecc";
      "inlineChat.background" = "#1e1e1ee6";
      "editorWidget.background" = "#1e1e1ee6";
      "editorHoverWidget.background" = "#1e1e1ee6";
      "editorSuggestWidget.background" = "#1e1e1ee6";
      "notifications.background" = "#1e1e1ee6";
      "notificationCenterHeader.background" = "#1e1e1ee6";
      "menu.background" = "#1e1e1ee6";
      "quickInput.background" = "#1e1e1ee6";
      "editor.lineHighlightBorder" = "#00000000";
    };
    "editor.tokenColorCustomizations" = {
      textMateRules = [
        {
          scope = [
            "comment"
            "entity.name.type.class"
            "keyword"
            "constant"
            "storage.modifier"
            "storage.type.class.js"
          ];
          settings = {
            fontStyle = "italic";
          };
        }
        {
          scope = [
            "invalid"
            "keyword.operator"
            "constant.numeric.css"
            "keyword.other.unit.px.css"
            "constant.numeric.decimal.js"
            "constant.numeric.json"
          ];
          settings = {
            fontStyle = "";
          };
        }
      ];
    };
    "search.exclude" = {
      "**/node_modules" = true;
      "**/bower_components" = true;
      "**/*.code-search" = true;
      "**/.fvm" = true;
    };
    "files.watcherExclude" = {
      "**/.fvm" = true;
    };
    "[dart]" = {
      "editor.formatOnSave" = true;
      "editor.formatOnType" = true;
      "editor.rulers" = [
        80
      ];
      "editor.selectionHighlight" = false;
      "editor.suggest.snippetsPreventQuickSuggestions" = false;
      "editor.suggestSelection" = "first";
      "editor.tabCompletion" = "onlySnippets";
      "editor.wordBasedSuggestions" = "off";
    };
    "dev.containers.dockerComposePath" = "docker compose";
    "docker.composeCommand" = "docker compose";
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "git.enableSmartCommit" = true;
    "github.copilot.enable" = {
      "*" = true;
      plaintext = false;
      markdown = false;
      scminput = false;
      yaml = true;
      dart = true;
    };
    "yaml.schemas" = {
      "https://api.bitbucket.org/schemas/pipelines-configuration" = "bitbucket-pipelines.yml";
    };
    "thunder-client.codeSnippetLanguage" = "cs-httpclient";
    "svelte.enable-ts-plugin" = true;
    "go.toolsManagement.autoUpdate" = true;
    "csharpextensions.privateMemberPrefix" = "_";
    "editor.tabSize" = 2;
    "[javascript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[python]" = {
      "editor.formatOnType" = true;
    };
    "Codegeex.Privacy" = true;
    "Codegeex.EnableExtension" = false;
    "docker.dockerPath" = "docker";
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    "auto-close-tag.disableOnLanguage" = [
      "typescript"
    ];
    "auto-close-tag.activationOnLanguage" = [
      "xml"
      "php"
      "blade"
      "ejs"
      "jinja"
      "javascript"
      "javascriptreact"
      "typescriptreact"
      "plaintext"
      "markdown"
      "mdx"
    ];
    "editor.linkedEditing" = true;
    "redhat.telemetry.enabled" = false;
    "nxConsole.showNodeVersionOnStartup" = false;
    "github.copilot.editor.enableAutoCompletions" = true;
    "github.copilot.nextEditSuggestions.enabled" = true;
    "yaml.disableSchemaDetection" = [
      "**/docker-compose.yml"
      "**/docker-compose.yaml"
      "**/docker-compose.*.yml"
      "**/docker-compose.*.yaml"
      "**/compose.yml"
      "**/compose.yaml"
      "**/compose.*.yml"
      "**/compose.*.yaml"
    ];
    "editor.unicodeHighlight.nonBasicASCII" = false;
    "js/ts.experimental.useTsgo" = true;
    "ollama.thinkingLevels" = {
      "qwen3.5:9b" = false;
    };
    "chat.byokUtilityModelDefault" = "mainAgent";
    "chat.utilityModel" = "";
    "chat.utilitySmallModel" = "";
    "lmstudio-copilot.serverUrl" = "http://localhost:1234";
    "claudeCode.preferredLocation" = "panel";
    "claudeCode.useTerminal" = true;
    "terminal.integrated.gpuAcceleration" = "off";
    "window.controlsStyle" = "custom";
    "extensions.supportAgentsWindow" = {
      "ltmoerdani.opencode-copilot-chat" = true;
    };
    "chat.titleBar.openInAgentsWindow.enabled" = false;
  };
  keybindings = [
    {
      key = "shift+enter";
      command = "workbench.action.terminal.sendSequence";
      args = {
        text = (builtins.fromJSON "\"\\u001b\\r\"");
      };
      when = "terminalFocus";
    }
    {
      key = "ctrl+shift+c c";
      command = "github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated";
    }
    {
      key = "ctrl+enter";
      command = "-github.copilot.generate";
      when = "editorTextFocus && github.copilot.activated";
    }
    {
      key = "ctrl+shift+'";
      command = "workbench.action.terminal.toggleTerminal";
      when = "terminal.active";
    }
    {
      key = "ctrl+shift+[BracketLeft]";
      command = "-workbench.action.terminal.toggleTerminal";
      when = "terminal.active";
    }
  ];
}
