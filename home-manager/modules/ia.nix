{
  pkgs,
  unstablePkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    # Anthropic Claude Code
    unstablePkgs.claude-code

    # GitHub Copilot CLI
    unstablePkgs.github-copilot-cli

    # OpenCode
    unstablePkgs.opencode
    # opencode-desktop

    # OpenAI Codex CLI
    unstablePkgs.codex

    # llmfit
    llmfit

    # Chatgpt desktop
    inputs.chatgpt-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Claude Desktop
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.claude-statusline.enable = true;
}
