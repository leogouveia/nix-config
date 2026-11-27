# Dicas

## Atualizar a grade de aplicativos do GNOME sem reiniciar a sessão

Depois de instalar um aplicativo pelo Home Manager, Nix ou Flatpak, o lançador pode demorar para aparecer na grade do GNOME. Para provocar uma nova indexação dos arquivos `.desktop`, crie e remova um arquivo temporário no diretório local de aplicativos:

```bash
mkdir -p ~/.local/share/applications &&
touch ~/.local/share/applications/.refresh.desktop &&
rm ~/.local/share/applications/.refresh.desktop
```

Após aplicar a configuração do Home Manager, o mesmo comando fica disponível nos terminais pelo alias:

```bash
appsrefresh
```

O comando funciona para outros aplicativos gerenciados pelo Home Manager, desde que o arquivo `.desktop` esteja em um diretório que a sessão atual conheça por meio de `XDG_DATA_DIRS`.

Para conferir esses diretórios:

```bash
printf '%s\n' "${XDG_DATA_DIRS//:/$'\n'}"
```

Se o Home Manager tiver acabado de adicionar um novo diretório a `XDG_DATA_DIRS`, o GNOME iniciado anteriormente ainda poderá estar usando o ambiente antigo. Nesse caso, a reindexação não será suficiente e será necessário encerrar e iniciar a sessão uma vez.

O comando `update-desktop-database` atualiza o banco de associações MIME dos lançadores, mas, isoladamente, não força a atualização da grade do GNOME.
