# Primeiros passos no NixOS recém-instalado

Checklist de pós-instalação do NixOS 26.05 para o repositório `leogouveia/nix-config`.

Comece após instalar e reiniciar conforme o [guia de instalação](installation.md). Execute os passos na sessão do usuário normal. Se você mudou de usuário durante a instalação, use o perfil correspondente no Home Manager.

## 1. Baixar o nix-config

- [ ] Clonar o repositório via HTTPS no diretório pessoal. Se já houver um checkout em `~/nix-config`, use-o.

```bash
git clone https://github.com/leogouveia/nix-config.git ~/nix-config
```

Se o Git ainda não estiver disponível, abra um shell com `nix-shell -p git` e execute o clone nele. O GitHub permite clonar repositórios públicos sem autenticação via HTTPS. Via SSH, ele exige uma chave autorizada mesmo para leitura de repositórios públicos. Depois de configurar o agente do 1Password, troque o remote para SSH na etapa de Git.

## 2. Vincular a configuração do sistema

- [ ] Preservar a configuração do host anterior, caso seja outra instalação.
- [ ] Copiar os arquivos da nova instalação para o host correspondente no repositório.

```bash
cp /etc/nixos/*.nix ~/nix-config/hosts/se4n-nixos/
```

Não sobrescrever a configuração de outro host. O `hardware-configuration.nix` recém-gerado contém os UUIDs da instalação atual. Conferir também se `/etc/nixos` ainda é um diretório real e se `/etc/nixos.bak` não existe antes de executar:

```bash
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -sT ~/nix-config/hosts/se4n-nixos /etc/nixos
sudo nixos-rebuild build
```

- [ ] Conferir o link e validar a compilação.

## 3. Home Manager

- [ ] Vincular a raiz do repositório ao diretório padrão do Home Manager, caso o destino ainda não exista.

```bash
ln -sT ~/nix-config ~/.config/home-manager
```

Se o destino já existir, inspecioná-lo antes de substituí-lo. Não criar um diretório `home-manager` antes do link.

- [ ] Aplicar a configuração como usuário normal.

```bash
cd ~/nix-config
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#leogouveia
```

- [ ] Encerrar a sessão e entrar novamente, se necessário.

## 4. Configurar o 1Password

O aplicativo e o CLI são instalados pelo NixOS. O Home Manager configura o SSH, a chave pública e a seleção de chaves no `agent.toml`.

- [ ] Entrar na conta do 1Password.
- [ ] Abrir **Configurações → Desenvolvedor**.
- [ ] Configurar e habilitar o agente SSH.
- [ ] Escolher **Usar nomes** para identificar as chaves nas solicitações de autorização (opcional).
- [ ] Pedir aprovação a cada nova sessão de aplicativo e terminal.
- [ ] Memorizar a aprovação até o 1Password bloquear.
- [ ] Manter desabilitada a geração de configuração SSH com hosts marcados, pois o Home Manager gerencia o SSH.
- [ ] Habilitar **Integrar com 1Password CLI**.

As preferências sensíveis do 1Password são autenticadas pelo aplicativo e precisam ser habilitadas manualmente. Não sobrescrever `~/.config/1Password/settings/settings.json` nem versionar suas tags de autenticação.

Verificar:

```bash
op --version
ls -l ~/.1password/agent.sock
ssh -T git@github.com
```

O GitHub deve confirmar a autenticação; é normal informar que não oferece acesso a shell.

## 5. Configurar o remote Git via SSH

- [ ] Depois de validar a autenticação SSH na etapa anterior, converter o `origin` para SSH caso esteja em HTTPS. Essa configuração vale para o repositório e permite usar a mesma autenticação no terminal e nos editores.

```bash
cd ~/nix-config
git remote -v
git remote set-url origin git@github.com:leogouveia/nix-config.git
git fetch
```

O `git fetch` verifica o acesso de leitura pelo novo remote. Para publicar alterações com `git push`, a conta autenticada precisa ter permissão de escrita.

## 6. Restaurar as configurações dos aplicativos com o yadm

O Home Manager instala o `yadm`, os editores, as ferramentas de IA e suas dependências, incluindo o `jq` para os hooks e a statusline do Claude Code. Ele também continua gerenciando o SSH e as extensões declaradas para o perfil padrão do VS Code.

O `yadm` gerencia os arquivos versionados no repositório de dotfiles, como as preferências e os atalhos do VS Code, o `settings.json` do Zed (incluindo a lista de extensões instaladas automaticamente) e os hooks e a statusline do Claude Code. Faça alterações nesses arquivos no repositório de dotfiles, não no `nix-config`.

- [ ] Revisar e aplicar a configuração do Home Manager e confirmar que a conta autenticada via SSH, com a chave do 1Password, tem acesso ao repositório privado de dotfiles.
- [ ] Antes do clone, guardar uma cópia das preferências locais que deseja preservar, especialmente as do Zed, Claude Code e Codex.
- [ ] Se já houver um repositório do `yadm` nesta home, conferir o remoto com `yadm remote -v` e a branch com `yadm branch --show-current` antes de atualizar, sem clonar novamente.
- [ ] Caso ainda não haja um repositório do `yadm` nesta home, clonar como usuário normal:

```bash
yadm clone -b nixos git@github.com:leogouveia/dotfiles.git
yadm status
```

O `-b nixos` seleciona a branch. O `yadm` restaura os arquivos em `~`, independentemente do diretório em que o comando for executado. Se houver colisões, revise os arquivos envolvidos e preserve as alterações locais antes de forçar qualquer restauração. Não versione credenciais nem tokens.

## 7. Conferir os aplicativos

- [ ] No VS Code, conferir as preferências e os atalhos restaurados pelo `yadm` e as extensões instaladas pelo Home Manager.
- [ ] No Zed, conferir as preferências restauradas e verificar se o editor consegue acessar o repositório sem solicitar credenciais HTTPS. Reconfigurar as credenciais dos provedores de IA, quando necessário.
- [ ] No Claude Code, conferir se a statusline aparece e se os hooks funcionam. Se houver falhas, verificar se `jq --version` funciona.

## 8. Validações opcionais

### Partição de backups

O host `se4n-nixos` monta a partição ext4 `se4n-lx-bk` em `/mnt/se4n-lx-bk` durante o boot. A configuração usa o UUID da partição e permite que o sistema inicie caso o disco esteja ausente.

- [ ] Após reiniciar, conferir a montagem com `findmnt --mountpoint /mnt/se4n-lx-bk`.
- [ ] Conferir se o volume aparece na barra lateral do Arquivos (Nautilus). A opção `x-gvfs-show` torna visível a montagem em `/mnt`.
- [ ] No Pika Backup, selecionar o repositório existente pelo caminho dentro de `/mnt/se4n-lx-bk`. Se o Pika estava configurado com o caminho anterior em `/run/media`, selecionar o mesmo repositório pelo novo caminho.

### Fontes

- [ ] Verificar as fontes instaladas pelo sistema e as montagens de compatibilidade FHS.

```bash
fc-list
findmnt -t fuse.bindfs
```

### Podman e NVIDIA

- [ ] Conferir o gerador CDI e testar a GPU em um container temporário.

```bash
systemctl status nvidia-container-toolkit-cdi-generator.service
podman run --rm --device nvidia.com/gpu=all registry.fedoraproject.org/fedora-toolbox:45 nvidia-smi
```

### Distrobox

- [ ] Caso seja necessário criar um ambiente Fedora, utilizar home separado e integração NVIDIA via CDI.

```bash
mkdir -p ~/Distrobox/fedora
distrobox create \
  --name fedora \
  --image registry.fedoraproject.org/fedora-toolbox:45 \
  --home "$HOME/Distrobox/fedora" \
  --additional-flags "--device=nvidia.com/gpu=all"
```

Se as flags CDI já estiverem declaradas nas configurações globais do Distrobox, não é necessário repeti-las. Não usar simultaneamente `--nvidia` neste fluxo CDI.

- [ ] Validar Vulkan e aplicativos gráficos dentro do container, se necessário.

```bash
sudo dnf install vulkan-tools gnome-text-editor
nvidia-smi
vulkaninfo --summary
gnome-text-editor
```

## 9. Finalização

- [ ] Revisar as alterações do host e do Home Manager.
- [ ] Versionar as alterações desejadas no Git.
- [ ] Registrar neste documento novas etapas manuais identificadas durante o uso.
