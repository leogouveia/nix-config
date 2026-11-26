# shellcheck shell=bash
# Funções compartilhadas pelo instalador e pelos hooks do Disko.

fail() {
  printf 'Erro: %s\n' "$*" >&2
  exit 1
}

inspect_uuid() {
  local uuid=$1 info type parent status=0
  [[ $uuid =~ ^[a-fA-F0-9]+(-[a-fA-F0-9]+)*$ ]] ||
    fail 'Informe o UUID do sistema de arquivos, conforme a coluna UUID do inventário.'
  [[ $EUID == 0 ]] || fail 'Execute como root para consultar o UUID nos dispositivos.'
  uuid_device=$(blkid -c /dev/null -t "UUID=$uuid" -o device) || status=$?
  [[ $status != 2 ]] || fail "UUID de sistema de arquivos não encontrado: $uuid"
  [[ $status == 0 ]] || fail "Não foi possível consultar o UUID: $uuid"
  [[ -n $uuid_device && $uuid_device != *$'\n'* ]] ||
    fail "O UUID $uuid precisa identificar exatamente um dispositivo."
  info=$(lsblk -dnro TYPE,PKNAME -- "$uuid_device") || fail "Não foi possível identificar $uuid_device."
  read -r type parent <<< "$info"
  case "$type" in
    disk) uuid_disk=$uuid_device ;;
    part)
      [[ -n $parent ]] || fail "Disco pai ausente para $uuid_device."
      uuid_disk="/dev/$parent"
      ;;
    *) fail "O UUID $uuid precisa estar em um disco físico ou em uma de suas partições diretas." ;;
  esac
}

by_id_for_disk() {
  local id
  # Todos os aliases considerados apontam para o mesmo disco já identificado.
  for id in /dev/disk/by-id/*; do
    if [[ -L $id && -b $id && $id -ef $1 &&
      $id =~ ^/dev/disk/by-id/[a-zA-Z0-9][a-zA-Z0-9_.:+-]*$ && ! $id =~ -part[0-9]+$ ]]; then
      printf '%s\n' "$id"
      return
    fi
  done
  fail "Identificador persistente por hardware indisponível para $1."
}

check_uuid_disk() {
  inspect_uuid "$1"
  [[ $uuid_disk -ef $disk_path ]] || fail "O UUID $1 não pertence ao disco selecionado."
}

inspect_disk() {
  local id=$1 info type read_only size
  [[ $id =~ ^/dev/disk/by-id/[a-zA-Z0-9][a-zA-Z0-9_.:+-]*$ && ! $id =~ -part[0-9]+$ ]] ||
    fail 'Informe um identificador de disco inteiro em /dev/disk/by-id/.'
  [[ -L $id && -b $id ]] || fail "Identificador inexistente ou sem dispositivo de bloco: $id"

  disk_path=$(realpath -e -- "$id") || fail "Não foi possível resolver $id."
  info=$(lsblk -bdnro KNAME,TYPE,RO,DISK-SEQ,SIZE -- "$disk_path") ||
    fail "Não foi possível inspecionar $disk_path."
  read -r disk_name type read_only disk_sequence size <<< "$info"
  disk_sysfs=$(realpath -e -- "/sys/class/block/$disk_name") ||
    fail "Dispositivo ausente no sysfs: $disk_path"
  [[ $type == disk && $disk_sysfs == /sys/devices/* && $disk_sysfs != /sys/devices/virtual/* ]] ||
    fail "O identificador precisa apontar para um disco físico inteiro: $id"
  [[ $read_only == 0 ]] || fail "Disco somente leitura: $id"
  [[ $disk_sequence =~ ^[0-9]+$ ]] || fail "Não foi possível identificar a conexão atual de $id."
  if [[ ! $size =~ ^[0-9]+$ ]] || ((size < 8589934592 + 256 * 1024 * 1024)); then
    fail "O disco precisa comportar a ESP de 8 GiB e o volume Btrfs: $id"
  fi
}

# Usa os identificadores do kernel para reconhecer aliases, bind mounts e
# partições do disco. Holders também detectam conjuntos md e device mapper.
check_available() (
  set +f
  shopt -s nullglob dotglob
  local node holder number mount_number source target mountinfo swaps loops member
  local mount_namespace init_namespace
  [[ $EUID == 0 ]] || fail 'Execute como root para verificar o uso do disco.'
  mount_namespace=$(readlink /proc/self/ns/mnt) || fail 'Não foi possível identificar o namespace atual.'
  init_namespace=$(readlink /proc/1/ns/mnt) || fail 'Não foi possível identificar o namespace do PID 1.'
  [[ $mount_namespace == "$init_namespace" ]] ||
    fail 'Execute no namespace de montagem do sistema (fora de contêineres).'

  mountinfo=$(findmnt --kernel --raw --noheadings --nofsroot --output MAJ:MIN,SOURCE,TARGET) ||
    fail 'Não foi possível ler as montagens do sistema.'
  swaps=$(swapon --show --raw --noheadings --output NAME) ||
    fail 'Não foi possível verificar o swap ativo.'
  loops=$(losetup --list --raw --noheadings --output BACK-MAJ:MIN) ||
    fail 'Não foi possível verificar os dispositivos loop.'

  for node in "$disk_sysfs" "$disk_sysfs"/*; do
    [[ $node == "$disk_sysfs" || -f $node/partition ]] || continue
    read -r number < "$node/dev" || fail "Não foi possível identificar ${node##*/}."
    for holder in "$node"/holders/*; do
      fail "${node##*/} tem um dependente ativo: ${holder##*/}."
    done
    while read -r mount_number source target; do
      if [[ $mount_number == "$number" || $source -ef /dev/${node##*/} ]]; then
        fail "${node##*/} está em uso por uma montagem em $target."
      fi
    done <<< "$mountinfo"
    while IFS= read -r source; do
      [[ ! $source -ef /dev/${node##*/} ]] || fail "Swap ativo em $source."
    done <<< "$swaps"
    [[ $'\n'$loops$'\n' != *$'\n'"$number"$'\n'* ]] ||
      fail "${node##*/} contém o arquivo de um dispositivo loop ativo."
    # Btrfs pode montar com um major:minor anônimo e usar vários discos.
    for member in /sys/fs/btrfs/*/devices/"${node##*/}"; do
      [[ ! -e $member ]] || fail "${node##*/} pertence a um Btrfs em uso."
    done
  done

  [[ -d /mnt && ! -L /mnt ]] || fail '/mnt precisa ser um diretório real.'
  while read -r mount_number source target; do
    case "$target" in
      /mnt|/mnt/*) fail "Já existe uma montagem em $target." ;;
    esac
  done <<< "$mountinfo"
  local entries=(/mnt/*)
  ((${#entries[@]} == 0)) || fail '/mnt precisa estar vazio.'
)

show_disk() {
  printf 'Disco selecionado: %s → %s\n' "$1" "$disk_path"
  lsblk -o PATH,TYPE,VENDOR,MODEL,SERIAL,SIZE,PTTYPE,PARTLABEL,FSTYPE,LABEL,UUID,PARTUUID,MOUNTPOINTS -- "$disk_path"
}

confirm_disk() {
  local answer
  [[ -t 0 ]] || fail 'A confirmação precisa ser feita em um terminal interativo.'
  printf '\nTodos os dados do disco selecionado serão perdidos.\nDigite %s para confirmar: ' "$1" >&2
  IFS= read -r answer || fail 'Confirmação cancelada.'
  [[ $answer == "$1" ]] || fail 'Confirmação divergente. Nenhum disco foi alterado.'
}

check_partition() {
  local id=$1 index=$2 path
  [[ -b $id-part$index ]] || fail "Partição esperada ausente: $id-part$index"
  path=$(realpath -e -- "$id-part$index") || fail "Não foi possível resolver $id-part$index."
  [[ -f $disk_sysfs/${path##*/}/partition &&
    $(< "$disk_sysfs/${path##*/}/partition") == "$index" ]] ||
    fail "A partição $id-part$index não corresponde ao disco selecionado."
}
