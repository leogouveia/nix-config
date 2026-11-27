{ ... }:
{
  programs.distrobox = {
    enable = true;

    settings = {
      container_manager = "podman";
      container_generate_entry = 0;
      container_manager_additional_flags = "--device=nvidia.com/gpu=all";
    };

    containers = {
      # fedora = {
      #   image = "docker.io/library/fedora:44";

      #   additional_packages = "git curl wget gcc make";

      #   entry = true;
      #   pull = true;
      #   replace = false;
      # };

      # ubuntu = {
      #   image = "docker.io/library/ubuntu:26.04";

      #   additional_packages = "build-essential git curl";

      #   entry = true;
      #   pull = true;
      #   replace = false;
      # };
    };
  };
}
