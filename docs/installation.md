# Instalação do NixOS com Disko

O Disko prepara **um disco inteiro** na instalação. O sistema instalado continua usando `/etc/nixos/configuration.nix` e o Home Manager continua independente. O script usa a revisão `de5708739256238fb912c62f03988815db89ec9a` do Disko, correspondente à [versão 1.13.0](https://github.com/nix-community/disko/releases/tag/v1.13.0).

## 1. Iniciar pelo Live ISO

Use o Live ISO oficial do NixOS 26.05 para x86-64, com rede, em modo UEFI. Mantenha a mídia montada em `/iso`. O fluxo padrão de boot do ISO fornece essa montagem e permite verificar seu dispositivo de origem. A opção `copytoram` elimina essa referência e é recusada. Prefira o console do ISO para evitar automontagens enquanto o Disko trabalha.

Faça backup do disco de destino. Se houver outros sistemas no mesmo disco, use outro disco inteiro. O procedimento apaga as partições do destino, inclusive uma ESP que já exista nele. Para instalações em discos separados, mantenha uma ESP por sistema e confira o número de série antes de prosseguir.

No ambiente live, abra um terminal e obtenha o checkout em um caminho que fique acessível durante a instalação. Use HTTPS se você tiver acesso ao repositório por esse meio ou copie um checkout local para o ambiente live.

```bash
nix-shell -p git
git clone https://github.com/leogouveia/nix-config.git
cd nix-config
```

## 2. Identificar o destino

```bash
scripts/list-disks.sh
```

Compare modelo, tamanho, número de série, partições e pontos de montagem. Copie **um identificador do disco inteiro** listado em `/dev/disk/by-id/`. Se houver vários aliases para o mesmo disco, escolha um com serial ou WWN. Um alias terminado em `-partN` aponta para uma partição. UUID e PARTUUID identificam o conteúdo ou as partições atuais e podem mudar no provisionamento.

Defina o valor em uma variável do terminal para reutilizá-lo nos próximos comandos. Substitua o exemplo pelo identificador que você conferiu.

```bash
DISCO='/dev/disk/by-id/IDENTIFICADOR-CONFERIDO'
```

## 3. Validar e preparar

```bash
sudo mkdir -p /mnt
sudo scripts/prepare-disk.sh --preview "$DISCO"
sudo scripts/prepare-disk.sh "$DISCO"
```

O preview confere o dispositivo e mostra o plano avaliado do `disk-config.nix` sem chamar o Disko. Ambos os modos exigem que `/mnt` esteja vazio, sem montagens, e recusam discos em uso. Se o script encontrar uma montagem, swap ativo ou um dispositivo dependente, confira a origem com `lsblk` e libere o recurso manualmente se for seguro. Se o disco pertencer ao sistema ou à mídia live, escolha outro. Em caso de dúvida sobre a origem da mídia ou uma topologia de armazenamento incomum, interrompa o procedimento.

Na execução, o Disko mostra o disco e o layout antes da primeira escrita. Digite o caminho `/dev/disk/by-id/…` completo no terminal para confirmar e aguarde a verificação final. As verificações são repetidas após a confirmação. Evite reconectar discos ou iniciar ferramentas de armazenamento durante a execução.

| Partição | Tamanho | Formato | Montagem no Live ISO |
| --- | --- | --- | --- |
| ESP (GPT `EF00`) | 8 GiB | FAT32 | `/mnt/boot` |
| Dados (GPT `8300`) | Espaço restante | Btrfs | Subvolumes abaixo |

| Subvolume | Montagem no Live ISO | Montagem no sistema |
| --- | --- | --- |
| `@root` | `/mnt` | `/` |
| `@home` | `/mnt/home` | `/home` |
| `@nix` | `/mnt/nix` | `/nix` |
| `@snapshots` | `/mnt/.snapshots` | `/.snapshots` |

Os quatro subvolumes usam `compress=zstd,noatime`. A ESP usa `fmask=0022,dmask=0022`. O script verifica a GPT, as partições, a origem das montagens e suas opções. Para conferir manualmente, execute

```bash
lsblk -o PATH,SIZE,TYPE,PTTYPE,PARTTYPE,PARTLABEL,FSTYPE,FSVER,UUID,PARTUUID,MOUNTPOINTS "$DISCO"
findmnt --submounts --mountpoint /mnt -o TARGET,SOURCE,FSTYPE,OPTIONS
```

Se o Disko falhar depois de começar a escrever, inspecione a tabela de partições e as montagens antes de repetir o procedimento. O Disko pode ter criado parte do layout. A execução usa `format,mount`; o hook de criação limpa as assinaturas dos dispositivos selecionados após a confirmação. O único desmonte durante a operação normal é o das montagens temporárias que o Disko cria no Btrfs para criar os subvolumes.

## 4. Gerar o hardware e revisar a configuração

```bash
sudo nixos-generate-config --root /mnt
sudo install -m 0644 hosts/se4n-nixos/configuration.nix /mnt/etc/nixos/configuration.nix
sudoedit /mnt/etc/nixos/configuration.nix
```

Use o `hardware-configuration.nix` recém-gerado em `/mnt/etc/nixos`. Confira que ele tem os novos UUIDs, os quatro subvolumes e a ESP em `/boot`. Caso tenha montado sistemas de arquivos adicionais sob `/mnt` após o Disko, confira se o gerador os incluiu e mantenha somente as entradas desejadas. O Disko fica fora dos imports do host. A configuração de hardware registra dispositivos, tipos e subvolumes, e a configuração principal acrescenta as opções Btrfs. O NixOS acrescenta `x-initrd.mount` à raiz e ao `/nix`; preserve a composição das listas de opções e os módulos de initrd detectados.

Revise os trechos específicos do host antes de instalar.

- Remova `fileSystems."/mnt/cachyos-home"` se o volume compartilhado do CachyOS estiver ausente. Se for manter a montagem, confira o UUID do Btrfs externo e o subvolume.
- Revise `boot.loader.limine.extraEntries`. Remova as entradas de sistemas ausentes. Para as entradas que mantiver, confira o PARTUUID da ESP de cada sistema com `lsblk` e o caminho do executável EFI correspondente. A ESP nova do NixOS fica montada em `/boot`; mantenha as outras ESPs separadas.
- Ajuste o nome do host, drivers específicos da máquina e a conta de usuário quando o hardware ou o usuário forem diferentes. Se trocar o usuário, ajuste também o perfil e o diretório pessoal declarados no Home Manager.

A instalação UEFI registra o Limine no firmware, pois o host usa `boot.loader.efi.canTouchEfiVariables = true`. Em multiboot, confira a ordem de boot no firmware depois da instalação.

## 5. Instalar e ativar o Home Manager

Com as montagens em `/mnt` e a configuração revisada, execute

```bash
sudo nixos-install --root /mnt
sudo nixos-enter --root /mnt -c 'passwd leogouveia'
sudo reboot
```

Inicialize pela ESP do novo disco. Entre como o usuário normal, obtenha o checkout em `~/nix-config` e aplique o perfil independente do Home Manager. Use a conta ajustada na etapa anterior, se for diferente.

```bash
git clone https://github.com/leogouveia/nix-config.git ~/nix-config
nix run github:nix-community/home-manager/release-26.05 -- switch --flake ~/nix-config#leogouveia
```

Se o Git ainda não estiver disponível, use `nix-shell -p git` para obter o checkout. A atualização posterior do sistema usa `sudo nixos-rebuild switch` com a configuração em `/etc/nixos`.

Consulte também o [guia rápido e a referência do Disko](https://github.com/nix-community/disko/tree/v1.13.0/docs) e o [manual de instalação do NixOS](https://nixos.org/manual/nixos/stable/#sec-installation).
