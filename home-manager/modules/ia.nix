{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Anthropic Claude Code
    claude-code

    # GitHub Copilot CLI
    github-copilot-cli

    # OpenCode
    opencode
    # opencode-desktop

    # OpenAI Codex CLI
    codex

    # llmfit
    llmfit
  ];

  programs.claude-statusline.enable = true;
}
