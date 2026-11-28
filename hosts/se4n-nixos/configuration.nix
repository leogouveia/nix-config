# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.1
    ./hardware-configuration.nix
    ./modules/fhs-compat.nix
    ./modules/fonts.nix
    ./modules/plymouth.nix
  ];

  # Permitir pacotes proprietários
  nixpkgs.config.allowUnfree = true;

  # Opções de montagem dos subvolumes Btrfs.
  #
  # NÃO usar lib.mkForce aqui. O tipo de fileSystems.<ponto>.options é uma
  # lista, e todas as definições são CONCATENADAS:
  #   - subvol=@... vem de ./hardware-configuration.nix
  #   - x-initrd.mount é adicionado automaticamente pelo NixOS para os
  #     filesystems de utils.pathsNeededForBoot (/, /nix, /nix/store,
  #     /var*, /etc, /usr) em nixos/modules/tasks/filesystems.nix
  # Um lib.mkForce descarta essas definições automáticas; foi exatamente
  # isso que removeu x-initrd.mount de /nix e quebrou o initrd
  # ("Failed to start Find NixOS closure").
  fileSystems."/".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/home".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/nix".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/.snapshots".options = [
    "compress=zstd"
    "noatime"
  ];

  fileSystems."/mnt/se4n-lx-bk" = {
    device = "/dev/disk/by-uuid/268c6603-7107-4fa6-b08f-143f42efaa7d";
    fsType = "ext4";
    options = [
      "nofail"
      "x-gvfs-show"
    ];
  };

  # Home do CachyOS, compartilhado entre os sistemas pelo subvolume Btrfs.
  #fileSystems."/mnt/cachyos-home" = {
  #  device = "/dev/disk/by-uuid/e149652a-4f50-439f-b2a9-6b270f3e46a0";
  #  fsType = "btrfs";
  #  options = [
  #    "subvol=@home"
  #    "compress=zstd"
  #    "noatime"
  #    "nofail"
  #  ];
  #};

  # Shell de resgate no initrd. Sem isto o /etc/shadow do initrd é
  # "root:*" e uma falha de initrd deixa a máquina sem nenhum acesso.
  # Acesso não autenticado, exige acesso físico ao console.
  boot.initrd.systemd.emergencyAccess = true;

  # Limine EFI bootloader
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;

    # Chainload dos outros sistemas, cada um na sua própria partição EFI.
    # Sintaxe conferida no CONFIG.md da tag v12.5.2 e nos símbolos do
    # BOOTX64.EFI instalado (limine 12.5.2):
    #   protocol: efi            -> aliases "uefi" e "efi_chainload"
    #   path:                    -> alias "image_path"
    #   uuid(...) / guid(...)    -> casa UUID de filesystem OU GUID de
    #                               partição GPT, em namespace unificado
    # Os valores abaixo são os PARTUUID (GUID de partição GPT) das ESPs.
    # Isto só escreve na ESP do NixOS; nada é alterado nas ESPs alheias.
    extraEntries = ''
      /Windows Boot Manager
          protocol: efi
          path: uuid(2c4e5de9-d219-444b-bbc2-5e9fe3ffe60d):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
    extraConfig = ''
      remember_last_entry: yes
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "se4n-nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Fuso horário de Brasília
  time.timeZone = "America/Sao_Paulo";

  # Idioma e localização
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LANGUAGE = "en_US:en";
    };
  };

  # Teclado americano internacional com dead keys
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Console de texto (TTY)
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.accounts-daemon.enable = true;

  systemd.services.gnome-user-avatar = {
    description = "Configurar o avatar de leogouveia no GNOME";
    wantedBy = [ "multi-user.target" ];
    requires = [ "accounts-daemon.service" ];
    after = [ "accounts-daemon.service" ];
    serviceConfig.Type = "oneshot";

    script = ''
      uid="$(${pkgs.coreutils}/bin/id -u leogouveia)"
      busctl=${pkgs.systemd}/bin/busctl

      "$busctl" --system call \
        org.freedesktop.Accounts /org/freedesktop/Accounts \
        org.freedesktop.Accounts FindUserById x "$uid" >/dev/null

      "$busctl" --system call \
        org.freedesktop.Accounts "/org/freedesktop/Accounts/User$uid" \
        org.freedesktop.Accounts.User SetIconFile \
        s "${../../assets/avatar_profissional.png}"
    '';
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Impressão via CUPS — Epson EcoTank L3250 (ESC/P-R)
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  # Enable sound.
  # Áudio com PipeWire
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ---------------------------------------------------------------- Bluetooth
  hardware.bluetooth.enable = true; # bluez, bluez-utils, bluez-obex...

  # NVIDIA RTX 3080 Ti
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Virtualização
  virtualisation.libvirtd.enable = true; # virt-manager (+ dnsmasq)
  programs.virt-manager.enable = true; # virt-manager
  # Lembrete: adicionar o usuário ao grupo "libvirtd" na etapa de usuários.
  # APROVAÇÃO: VirtualBox (módulo próprio; conflita com KVM em uso simultâneo).
  # virtualisation.virtualbox.host.enable = true;   # virtualbox, virtualbox-host-dkms

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.leogouveia = {
    isNormalUser = true;
    description = "Leonardo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "kvm"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    #   settings = {
    #     PasswordAuthentication = false;
    #     PermitRootLogin = "no";
    #   };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # 1Password — aplicativo, CLI e integração com navegadores
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "leogouveia" ];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      .zen-wrapped
      zen
    '';
    mode = "0755";
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # Ferramentas administrativas
  environment.systemPackages = with pkgs; [
    btrfs-progs
    smartmontools
    system-config-printer
    usbutils
    dmidecode
    efibootmgr
    ethtool
    pciutils
    lshw
    gjs
  ];

  environment.gnome.excludePackages = [ pkgs.epiphany ];

  # Atualizações de firmware
  services.fwupd.enable = true;
  programs.firefox.enable = true;
  programs.vim.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  services.flatpak.enable = true;
  programs.nix-ld.enable = true;
  programs.git.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  # Integração NVIDIA com containers
  hardware.nvidia-container-toolkit = {
    enable = true;

    mounts = [
      {
        hostPath = "${pkgs.writeText "10_nvidia.json" (
          builtins.toJSON {
            file_format_version = "1.0.0";
            ICD.library_path = "libEGL_nvidia.so.0";
          }
        )}";

        containerPath = "/usr/share/glvnd/egl_vendor.d/10_nvidia.json";
      }
      {
        hostPath = "${pkgs.writeText "nvidia_icd.json" (
          builtins.toJSON {
            file_format_version = "1.0.1";
            ICD = {
              library_path = "libGLX_nvidia.so.0";
              api_version = "1.4.329";
            };
          }
        )}";

        containerPath = "/usr/share/vulkan/icd.d/nvidia_icd.json";
      }
    ];
  };

  # Suporte gráfico para aplicativos de 32 bits
  hardware.graphics.enable32Bit = true;

}
