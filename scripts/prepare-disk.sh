#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Uso: %s [--preview] {--uuid UUID | /dev/disk/by-id/IDENTIFICADOR}\n' "${0##*/}"
}

preview=no
case ${1-} in
  --help|-h) usage; exit 0 ;;
  --preview) preview=yes; shift ;;
esac
selection_uuid=''
if [[ $# == 2 && $1 == --uuid && -n $2 ]]; then
  selection_uuid=$2
elif [[ $# == 1 && -n $1 && $1 != -* ]]; then
  disk_id=$1
else
  usage >&2
  printf 'Erro: forneça explicitamente o UUID do sistema de arquivos ou o identificador do disco inteiro.\n' >&2
  exit 2
fi

script_dir=$(dirname "$(realpath -e -- "${BASH_SOURCE[0]}")")
# shellcheck source=scripts/disk-safety.sh
source "$script_dir/disk-safety.sh"
config_file="$script_dir/../disk-config.nix"

if [[ -n $selection_uuid ]]; then
  inspect_uuid "$selection_uuid"
  disk_id=$(by_id_for_disk "$uuid_disk")
fi
inspect_disk "$disk_id"
if [[ -n $selection_uuid ]]; then
  check_uuid_disk "$selection_uuid"
fi
check_available
sequence=$disk_sequence
if [[ $preview == yes ]]; then
  show_disk "$disk_id"
  if [[ -n $selection_uuid ]]; then
    printf 'UUID selecionado: %s em %s\n' "$selection_uuid" "$uuid_device"
  fi
  printf '\nEstrutura a criar em /mnt\n'
  nix --extra-experimental-features nix-command eval --impure --raw \
    --file "$config_file" --argstr disk "$disk_id" preview
  printf '\nValidação concluída. Nenhum dispositivo foi alterado.\n'
  exit 0
fi

[[ -t 0 ]] || fail 'Execute em um terminal interativo.'
exec 9>/run/lock/nixos-prepare-disk.lock
flock -n 9 || fail 'Já existe uma preparação de disco em andamento.'

# Disko v1.13.0. O hook de criação repete a validação e pede a confirmação
# depois de o Nix resolver as dependências e antes da primeira escrita.
disko=github:nix-community/disko/de5708739256238fb912c62f03988815db89ec9a
if ! nix --extra-experimental-features 'nix-command flakes' run "$disko" -- \
  --mode format,mount --argstr disk "$disk_id" --argstr expectedDiskSequence "$sequence" \
  --argstr selectionUuid "$selection_uuid" "$config_file"; then
  fail 'Disko interrompido. Se a formatação já havia começado, confira o estado com lsblk e findmnt antes de tentar novamente.'
fi

inspect_disk "$disk_id"
[[ $disk_sequence == "$sequence" ]] || fail 'O dispositivo mudou durante o provisionamento.'
check_partition "$disk_id" 1
check_partition "$disk_id" 2
esp="$disk_id-part1"
data="$disk_id-part2"

[[ $(lsblk -dnro PTTYPE -- "$disk_id") == gpt &&
  $(lsblk -dnro PARTTYPE -- "$esp") == c12a7328-f81f-11d2-ba4b-00a0c93ec93b &&
  $(lsblk -dnro PARTTYPE -- "$data") == 0fc63daf-8483-4772-8e79-3d69d8477de4 &&
  $(lsblk -bdnro SIZE -- "$esp") == 8589934592 &&
  $(blkid -p -s VERSION -o value -- "$esp") == FAT32 ]] ||
  fail 'A GPT, o tamanho da ESP, o FAT32 ou o tipo das partições divergem do layout esperado.'
partitions=$(lsblk -nr -o TYPE -- "$disk_id")
[[ $partitions == $'disk\npart\npart' ]] || fail 'O disco deveria ter exatamente duas partições.'

# O sysfs expressa início e tamanho em setores de 512 bytes. Admita a folga
# de alinhamento e a GPT de backup no final do disco.
data_path=$(realpath -e -- "$data")
data_sysfs="$disk_sysfs/${data_path##*/}"
read -r data_start < "$data_sysfs/start"
read -r data_size < "$data_sysfs/size"
read -r disk_size < "$disk_sysfs/size"
read -r logical_sector_size < "$disk_sysfs/queue/logical_block_size"
remaining=$((disk_size - data_start - data_size))
((remaining > 0 && remaining * 512 <= 4096 * logical_sector_size)) ||
  fail 'O Btrfs não ocupa o espaço restante do disco.'

check_mount() {
  local target=$1 device=$2 type=$3 fsroot=$4 row source actual_type actual_root options
  row=$(findmnt --kernel --raw --noheadings --nofsroot --output SOURCE,FSTYPE,FSROOT,OPTIONS --mountpoint "$target") ||
    fail "Montagem ausente em $target."
  read -r source actual_type actual_root options <<< "$row"
  [[ $row != *$'\n'* && $source -ef $device && $actual_type == "$type" && $actual_root == "$fsroot" ]] ||
    fail "Dispositivo, filesystem ou subvolume inesperado em $target."
  case "$type" in
    btrfs)
      [[ ,$options, == *,noatime,* && ,$options, =~ ,compress=zstd(:[0-9]+)?, ]] ||
        fail "Compressão Zstandard ou noatime ausente em $target."
      ;;
    vfat)
      [[ ,$options, == *,fmask=0022,* && ,$options, == *,dmask=0022,* ]] ||
        fail "Máscaras da ESP divergentes em $target."
      ;;
  esac
}

check_mount /mnt              "$data" btrfs /@root
check_mount /mnt/home         "$data" btrfs /@home
check_mount /mnt/nix          "$data" btrfs /@nix
check_mount /mnt/.snapshots   "$data" btrfs /@snapshots
check_mount /mnt/boot         "$esp"  vfat  /

findmnt --submounts --mountpoint /mnt -o TARGET,SOURCE,FSTYPE,OPTIONS
lsblk -o PATH,TYPE,FSTYPE,UUID,PARTUUID -- "$disk_id"
printf '\nParticionamento e montagens validados.\n'
