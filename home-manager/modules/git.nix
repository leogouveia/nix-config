{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Leonardo de Albuquerque Gouveia";
        email = "leogouv@gmail.com";
      };

      init.defaultBranch = "main";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        IdentityFile = "~/.ssh/github.pub";
        IdentitiesOnly = true;
      };

      "*".IdentityAgent = "~/.1password/agent.sock";
    };
  };

  # Chave pública da "GitHub SSH" do 1Password (não é segredo)
  home.file.".ssh/github.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPX5g6MxbipbOQoQ60GVT1AtZ6EkFV20UAXgSzwZ/H1L";

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "thtsysqacs6n3ln6prpy2xgfoe"
    vault = "2yqmvubyvgxe7u5sd6vyhc2bzi"
  '';
}
