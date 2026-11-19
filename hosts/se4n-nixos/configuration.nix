# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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

  # Home do CachyOS, compartilhado entre os sistemas pelo subvolume Btrfs.
  fileSystems."/mnt/cachyos-home" = {
    device = "/dev/disk/by-uuid/e149652a-4f50-439f-b2a9-6b270f3e46a0";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
      "nofail"
    ];
  };

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

      /CachyOS (GRUB)
          protocol: efi
          path: uuid(d52aed40-1dea-4fa0-a25c-a87e6b14b0f4):/EFI/cachyos/grubx64.efi
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

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # irtualização
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
    usbutils
    dmidecode
    efibootmgr
    ethtool
    pciutils
    lshw
    gjs
  ];

  # Atualizações de firmware
  services.fwupd.enable = true;
  programs.firefox.enable = true;
  programs.vim.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  services.flatpak.enable = true;

  # Suporte gráfico para aplicativos de 32 bits
  hardware.graphics.enable32Bit = true;

}
