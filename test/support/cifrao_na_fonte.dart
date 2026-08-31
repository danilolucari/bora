/// As formas em que o cifrão de fato aparece numa **fonte Dart**.
///
/// Este é o detalhe que fazia o guard de MONT-08 passar por cima da infração
/// real. Em Dart, `$` inicia interpolação: dentro de uma string comum o cifrão
/// **só existe escapado** — na fonte ficam três caracteres, `R`, barra
/// invertida, `$`. A forma contígua `R$` só aparece em raw string (`r'R$ …'`)
/// ou em comentário.
///
/// Uma varredura que procurasse apenas a forma contígua acusaria a raw string
/// e deixaria passar a forma que um infrator de verdade escreveria.
const List<String> formasDoCifraoNaFonte = [r'R$', r'R\$'];

/// As formas do cifrão encontradas em [fonte] — vazio quando ela está limpa.
///
/// Recebe a fonte como ela está **no disco** (ou já sem comentários, quando
/// quem chama quiser permitir a citação da spec em prosa): o que importa é que
/// a comparação seja feita contra a fonte, não contra a string já
/// desescapada.
List<String> cifraoEm(String fonte) => [
      for (final forma in formasDoCifraoNaFonte)
        if (fonte.contains(forma)) forma,
    ];
