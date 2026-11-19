{ pkgs, inputs, ... }:

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

    # Chatgpt desktop
    inputs.chatgpt-desktop.packages.${pkgs.system}.default

    # Claude Desktop
    inputs.claude-desktop.packages.${pkgs.system}.default
  ];
  programs.claude-statusline.enable = true;
}
