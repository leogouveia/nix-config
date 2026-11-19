{ pkgs, ... }:

{
  home.packages = with pkgs; [
    celluloid
    decibels
    showtime
    vlc
  ];
}
