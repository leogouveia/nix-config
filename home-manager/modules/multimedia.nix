{ pkgs, ... }:

{
  home.packages = with pkgs; [
    celluloid
    decibels
    showtime
    spotdl
    vlc
  ];
}
