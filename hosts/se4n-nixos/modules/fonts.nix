{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;

    packages = with pkgs; [
      # ── Interface e documentos ──────────────────
      cantarell-fonts
      dejavu_fonts
      liberation_ttf
      open-sans
      ttf_bitstream_vera

      # ── Família Noto ────────────────────────────
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      # ── Programação — fontes originais ──────────
      fantasque-sans-mono
      jetbrains-mono
      maple-mono.NF
      monaspace

      # ── Nerd Fonts ──────────────────────────────
      nerd-fonts.blex-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.commit-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.monaspace
      nerd-fonts.recursive-mono
      nerd-fonts.victor-mono
    ];
  };
}
