#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

disks=$(lsblk -dnro PATH,TYPE)
aliases=(/dev/disk/by-id/*)
found=no
while read -r device type; do
  [[ $type == disk ]] || continue
  sysfs=$(realpath -e "/sys/class/block/${device##*/}")
  [[ $sysfs != /sys/devices/virtual/* ]] || continue
  found=yes
  printf '\n=== %s ===\n' "$device"
  lsblk -o PATH,TYPE,VENDOR,MODEL,SERIAL,TRAN,SIZE,PTTYPE,PARTLABEL,FSTYPE,LABEL,UUID,PARTUUID,MOUNTPOINTS -- "$device"
  printf 'Identificadores persistentes do disco inteiro\n'
  has_alias=no
  for id in "${aliases[@]}"; do
    if [[ -L $id && -b $id && $id -ef $device ]]; then
      printf '  %s\n' "$id"
      has_alias=yes
    fi
  done
  if [[ $has_alias == no ]]; then
    printf '  Nenhum identificador by-id disponível.\n'
  fi
done <<< "$disks"

if [[ $found == no ]]; then
  printf 'Nenhum disco físico encontrado.\n'
else
  printf '\nPara selecionar pelo sistema de arquivos, copie o valor da coluna UUID e use prepare-disk.sh --preview --uuid UUID.\n'
fi
