{
  disk ? null,
  mode ? "format,mount",
  rootMountPoint ? "/mnt",
  expectedDiskSequence ? "",
  selectionUuid ? "",
  ...
}:
let
  safety = builtins.toFile "disk-safety.sh" (builtins.readFile ./scripts/disk-safety.sh);
  espSizeGiB = "8";
  espOptions = [
    "fmask=0022"
    "dmask=0022"
  ];
  btrfsOptions = [
    "compress=zstd"
    "noatime"
  ];
  subvolumes = {
    "/@root".mountpoint = "/";
    "/@home".mountpoint = "/home";
    "/@nix".mountpoint = "/nix";
    "/@snapshots".mountpoint = "/.snapshots";
  };
  preview = ''
    GPT
      1. ESP de ${espSizeGiB} GiB, FAT32 em /mnt/boot (${builtins.concatStringsSep "," espOptions})
      2. Btrfs no espaço restante (${builtins.concatStringsSep "," btrfsOptions})
    ${builtins.concatStringsSep "\n" (
      map (name: "     ${name} → /mnt${subvolumes.${name}.mountpoint}") (builtins.attrNames subvolumes)
    )}
  '';
  inspect = ''
    set +x
    source "${safety}"
    inspect_disk '${disk}'
    [[ -z '${expectedDiskSequence}' || $disk_sequence == '${expectedDiskSequence}' ]] ||
      fail 'O dispositivo associado ao identificador mudou.'
  '';
  partitionHook = index: action: ''
    (
      ${inspect}
      check_partition '${disk}' ${index}
      check_available
      ${action}
    )
  '';
  partition = index: "${disk}-part${index}";
  # O UUID identifica o conteúdo antigo. Depois da confirmação, o Disko usa
  # exclusivamente o identificador persistente de hardware.
  verifyUuid = if selectionUuid == "" then "" else "check_uuid_disk '${selectionUuid}'";
  confirmation = if selectionUuid == "" then disk else selectionUuid;
in
if disk == null || disk == "" then
  throw "Informe explicitamente o disco com --argstr disk /dev/disk/by-id/IDENTIFICADOR."
else if
  !builtins.isString disk
  || builtins.match "/dev/disk/by-id/[a-zA-Z0-9][a-zA-Z0-9_.:+-]*" disk == null
  || builtins.match ".*-part[0-9]+" disk != null
  || !builtins.pathExists disk
then
  throw "O identificador precisa ser um /dev/disk/by-id/ existente, de disco inteiro."
else if mode != "format,mount" || rootMountPoint != "/mnt" then
  throw "Este layout de instalação exige o modo format,mount e o destino /mnt."
else if builtins.match "[0-9]*" expectedDiskSequence == null then
  throw "Número de sequência de disco inválido."
else if
  selectionUuid != "" && builtins.match "[a-fA-F0-9]+(-[a-fA-F0-9]+)*" selectionUuid == null
then
  throw "UUID de sistema de arquivos inválido."
else
  {
    inherit preview;
    disko.devices.disk.nixos = {
      type = "disk";
      device = disk;
      # Os caminhos das partições são vinculados ao disco e independentes de
      # labels GPT que podem se repetir em outras instalações.
      preMountHook = ''
        (
          ${inspect}
          check_partition '${disk}' 1
          check_partition '${disk}' 2
        )
      '';
      content = {
        type = "gpt";
        # O modo destroy do Disko desmonta /mnt recursivamente. Limpe apenas
        # as assinaturas do destino antes de o Disko criar a tabela GPT.
        preCreateHook = ''
          ${inspect}
          check_available
          ${verifyUuid}
          show_disk '${disk}'
          ${
            if selectionUuid == "" then
              ""
            else
              "printf 'UUID selecionado: %s em %s\\n' '${selectionUuid}' \"$uuid_device\""
          }
          printf '\n%s' '${preview}'
          confirmed_sequence=$disk_sequence
          confirm_disk '${confirmation}'
          inspect_disk '${disk}'
          [[ $disk_sequence == "$confirmed_sequence" ]] || fail 'O dispositivo mudou durante a confirmação.'
          ${verifyUuid}
          check_available
          wipefs --lock=yes --all -- '${disk}'
          udevadm settle --timeout=30
        '';
        partitions = {
          ESP = {
            size = "${espSizeGiB}G";
            type = "EF00";
            device = partition "1";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [
                "-F"
                "32"
              ];
              mountpoint = "/boot";
              mountOptions = espOptions;
              # Assinaturas antigas podem sobreviver nos offsets das novas partições.
              preCreateHook = partitionHook "1" "wipefs --lock=yes --all -- '${partition "1"}'";
            };
          };
          root = {
            size = "100%";
            type = "8300";
            device = partition "2";
            content = {
              type = "btrfs";
              preCreateHook = partitionHook "2" "wipefs --lock=yes --all -- '${partition "2"}'";
              subvolumes = builtins.mapAttrs (_: volume: volume // { mountOptions = btrfsOptions; }) subvolumes;
            };
          };
        };
      };
    };
  }
