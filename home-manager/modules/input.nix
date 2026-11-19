{ ... }:

# Compose do IBus: restaura "dead key + espaço" e o cedilha no layout us(intl).
#
# SINTOMA ORIGINAL
#   Com layout us(intl) e locale pt_BR.UTF-8, "acento + letra" funciona
#   (`'`+`a` = á), mas "acento + espaço" não finaliza a composição: a dead key
#   fica pendente (sublinhada) e nenhum caractere é emitido. Atinge todo
#   aplicativo que passa pelo IBus — Firefox, Zed, GTK e terminal.
#
# CAUSA
#   Mudança intencional do IBus 1.5.32, commit 7c2b32b4 "src: Do not load en-US
#   compose table by default" (seguindo o GTK4 >= 4.18.5). A tabela compose
#   en-US deixou de ser carregada por padrão, e com ela se foram todas as regras
#   <dead_*> <space>, que existem SÓ nela.
#
#   Morde especificamente locales cujo Compose de sistema é um arquivo fino de
#   overrides que faz `include` do en_US — pt_BR, el_GR, fi_FI. O
#   pt_BR.UTF-8/Compose tem 24 linhas: o include do en_US (5.192 linhas) mais 10
#   overrides, entre eles `<dead_acute> <c> : "ç"` (o en_US daria "ć"). Quem usa
#   o sistema em en_US.UTF-8 carrega a tabela cheia direto e nunca vê o
#   problema.
#
#   Referências:
#     https://github.com/ibus/ibus/commit/7c2b32b4   (a mudança de comportamento)
#     Debian #1098736  "ibus 1.5.32~beta2-2 breaks <dead_key> + <space> on
#                       US intl layout"               (mesmo sintoma)
#     https://github.com/ibus/ibus/issues/2825        (relato no Fedora, pt_BR)
#
# POR QUE AS REGRAS ESTÃO ESCRITAS À MÃO AQUI
#   O workaround canônico do upstream é `include "%L"`, a palavra-chave que o
#   próprio 7c2b32b4 criou para reativar as sequências embutidas. Ela resolve o
#   "acento + espaço" — porém, no IBus 1.5.33 (o do canal nixos-26.05), a mera
#   existência de um Compose de usuário desloca a tabela do locale, que deixa de
#   vencer o en_US: `'`+`c` passa a dar "ć". Verificado por digitação.
#
#   Essa ordenação só foi corrigida DEPOIS do 1.5.33, no commit 0ed5687
#   "Order locale compose and user compose". Com IBus 1.5.34 o `include "%L"`
#   sozinho funciona por completo — também verificado por digitação aqui.
#
#   Logo: enquanto o canal estiver no 1.5.33, declaram-se as 15 regras — as 5 de
#   dead key + espaço e os 10 overrides do pt_BR.UTF-8/Compose.
#
#   QUANDO O CANAL CHEGAR A IBus >= 1.5.34, este arquivo pode ser reduzido a:
#       xdg.configFile."ibus/Compose".text = ''
#         include "%L"
#       '';
#   (comprovadamente suficiente naquela versão). Verificar a versão com
#   `ibus version` antes de simplificar, e revalidar `'`+`c` e `'`+espaço.
#
# ATENÇÃO operacional
#   O IBus indexa o cache compilado pelo CAMINHO do arquivo e reaproveita cache
#   obsoleto quando o conteúdo muda. Ao editar este módulo:
#     rm -f ~/.cache/ibus/compose/*.cache && ibus restart
#   Estado correto: o cache do arquivo de usuário com n_seqs=15. Conferir com:
#     od -A none -t u2 -j 16 -N 8 ~/.cache/ibus/compose/*.cache

{
  xdg.configFile."ibus/Compose".text = ''
    # --- As regras que faltavam: dead key + espaço ---------------------------
    <dead_acute> <space>		: "'"	apostrophe
    <dead_grave> <space>		: "`"	grave
    <dead_tilde> <space>		: "~"	asciitilde
    <dead_circumflex> <space>	: "^"	asciicircum
    <dead_diaeresis> <space>	: "\""	quotedbl

    # --- Os 10 overrides do pt_BR.UTF-8/Compose, repostos --------------------
    # Necessários porque a presença deste arquivo desloca a tabela do locale no
    # IBus 1.5.33 (ver 0ed5687, acima). Sem eles, `'`+`c` regride para "ć".
    <dead_acute> <C>			: "Ç"	Ccedilla
    <dead_acute> <c>			: "ç"	ccedilla
    <Multi_key> <quotedbl> <backslash>	: "〝"	U301d
    <Multi_key> <quotedbl> <slash>	: "〞"	U301e
    <Multi_key> <comma> <E>		: "Ȩ"	U0228
    <Multi_key> <comma> <e>		: "ȩ"	U0229
    <Multi_key> <U> <comma> <E>		: "Ḝ"	U1E1C
    <Multi_key> <U> <comma> <e>		: "ḝ"	U1E1D
    <Multi_key> <acute> <U03D2>		: "ϓ"	U03D3
    <Multi_key> <apostrophe> <U03D2>	: "ϓ"	U03D3
  '';
}
