/// A visão **tipada** do estado inicial de RN-30 — CALC-06.
///
/// Derivada, nunca copiada: cada valor aqui é lido de `rn30_estado_inicial
/// .dart`, que continua sendo a **única** fonte da verdade. Repetir os
/// literais criaria uma segunda fonte, e as duas divergiriam no primeiro
/// ajuste. Por isso este arquivo não contém nenhum texto de RN-30 — só
/// conversão.
///
/// O dado bruto e o teste dele são **intocados**: a fundação provou por
/// mutação que aquelas asserções discriminam (a ausência de `dieta`/`bebe` na
/// Duda e o "todo valor é primitivo"), e reescrevê-las apagaria a prova.
/// Tipar é acrescentar uma leitura, não editar a fonte.
///
/// Duas coisas de RN-30 **não** têm lugar em [Festa] e por isso continuam só
/// no bruto: `confirmadosNaHome` e `pendentesNaHome`. São os contadores da
/// Home, que a spec 04 reconcilia — a fixture não reconcilia (o próprio teste
/// da fixture bruta afirma que 4 + 2 não fecha com as 5 pessoas nomeadas).
library;

import 'package:bora/core/calculo/calculo.dart';

import 'rn30_estado_inicial.dart';

/// A festa exemplo de RN-30, tipada.
///
/// `status` não vem do bruto: RN-30 não o declara, e o default de [Festa] é
/// [StatusDaFesta.chegando] — a festa do exemplo ainda vai acontecer.
final Festa festaRn30Tipada = Festa(
  nome: festaRn30['nome']! as String,
  data: festaRn30['data']! as String,
  hora: festaRn30['hora']! as String,
  local: festaRn30['local']! as String,
  duracaoHoras: festaRn30['duracaoHoras']! as int,
);

/// As cinco pessoas nomeadas de RN-30, tipadas e **na ordem do bruto**.
final List<Pessoa> pessoasRn30Tipadas = [
  for (final bruta in pessoasRn30) pessoaTipada(bruta),
];

/// Os sete itens padrão de RN-30, resolvidos para [ChaveItem].
final List<ChaveItem> itensPadraoRn30Tipados = [
  for (final chave in itensPadraoRn30) itemTipado(chave),
];

/// Converte uma pessoa bruta de RN-30 em [Pessoa].
///
/// `dieta` e `bebe` **preservam a ausência**: a chave não está no mapa da
/// Duda, então o campo chega `null` — nunca [Dieta.tudo], nunca `false`
/// (A-08). Ausente significa "a spec não define", e é diferente de declarado.
/// Fabricar um default aqui faria RN-21 contá-la como quem não bebe e mudaria
/// a quantidade de cerveja.
Pessoa pessoaTipada(Map<String, Object?> bruta) => Pessoa(
      nome: bruta['nome']! as String,
      papel: PapelNaFesta.porChave(bruta['papel']! as String)!,
      status: StatusDePresenca.porChave(bruta['status']! as String)!,
      dieta: dietaTipada(bruta['dieta']),
      bebe: bruta['bebe'] as bool?,
      voce: bruta['voce']! as bool,
    );

/// Converte a dieta bruta, distinguindo **ausente** de **desconhecida**.
///
/// - `null` na entrada ⇒ `null` na saída: a spec não declara (A-08).
/// - chave declarada e conhecida ⇒ o [Dieta] correspondente.
/// - chave declarada e **desconhecida** ⇒ **erro**, nunca `null`.
///
/// A terceira linha é o motivo desta função existir. `Dieta.porChave` devolve
/// `null` para chave desconhecida, e deixar esse `null` passar confundiria
/// "não declarado" com "não reconhecido" — a distinção que A-08 protege.
Dieta? dietaTipada(Object? bruta) {
  if (bruta == null) return null;

  final dieta = Dieta.porChave(bruta as String);
  if (dieta == null) {
    throw ArgumentError.value(bruta, 'dieta', 'dieta desconhecida em RN-30');
  }

  return dieta;
}

/// Resolve a chave bruta de um item para [ChaveItem].
///
/// Chave desconhecida **quebra o teste** em vez de virar item inventado:
/// `ChaveItem.porChave` devolve `null` justamente para quem converte decidir,
/// e a decisão aqui é falhar alto. Um item fabricado entraria no cálculo com
/// preço-base fabricado.
ChaveItem itemTipado(String chave) {
  final item = ChaveItem.porChave(chave);
  if (item == null) {
    throw ArgumentError.value(chave, 'item', 'item desconhecido em RN-30');
  }

  return item;
}
