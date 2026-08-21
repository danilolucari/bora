import 'dart:math' as math;

import '../dominio/dieta.dart';
import '../dominio/pessoa.dart';

/// O que as preferências da galera fazem com a lista — RN-21 · CALC-15.
///
/// Guarda **dois números que parecem um só** e nunca podem ser confundidos:
///
/// - [bebem] conta as pessoas **nomeadas** que declararam beber, e é o número
///   que aparece no resumo de RN-21 ("… · 3 bebem 🍺");
/// - [adultosQueBebem] é a base que **dimensiona a cerveja** em RN-05, e vale
///   `max(0, adultos − nomeadas com bebe == false)` (A-06).
///
/// Trocar um pelo outro estraga a conta em silêncio: com 6 adultos e a
/// primeira pessoa nomeada declarando que bebe, [bebem] é 1 e
/// [adultosQueBebem] é 6 — 18 latas, não 3. Subtrair os abstêmios conhecidos é
/// contínuo; contar só os nomeados que bebem daria um degrau que RN-05 não
/// autoriza.
class EfeitosDasPreferencias {
  const EfeitosDasPreferencias({
    required this.veggies,
    required this.semPorco,
    required this.bebem,
    required this.adultosQueBebem,
  });

  /// Pessoas nomeadas com dieta veggie.
  final int veggies;

  /// Pessoas nomeadas que não comem porco.
  final int semPorco;

  /// Pessoas nomeadas que declararam beber — o número do **resumo** de RN-21.
  final int bebem;

  /// A base de RN-05 depois de RN-21 — o número que **dimensiona a cerveja**.
  final int adultosQueBebem;

  /// RN-21: uma pessoa veggie já basta para o kit de legumes entrar na lista.
  bool get incluirKitVeggie => veggies >= 1;

  /// RN-21: uma pessoa sem porco já basta para a suína sair, mesmo
  /// selecionada.
  bool get removerSuina => semPorco >= 1;
}

/// Apura os efeitos das preferências das pessoas nomeadas — RN-21 · CALC-15.
///
/// [adultos] vem da contagem de RN-01 (steppers H/M/C), que cobre confirmados
/// e extras sem app; as pessoas nomeadas entram aqui com **preferências**,
/// nunca com cabeça (A-05).
///
/// `dieta == null` e `bebe == null` significam *não declarado* e **não**
/// contam — nem como veggie, nem como abstêmia (A-08). É o caso da Duda de
/// RN-30: ninguém sabe se ela bebe, então ela não tira cerveja da festa.
///
/// Sem nenhuma pessoa nomeada, `adultosQueBebem == adultos` e RN-05 fica
/// intacta.
EfeitosDasPreferencias efeitosDasPreferencias({
  required List<Pessoa> pessoas,
  required int adultos,
}) {
  var veggies = 0;
  var semPorco = 0;
  var bebem = 0;
  var abstemios = 0;

  for (final pessoa in pessoas) {
    if (pessoa.dieta == Dieta.veggie) veggies++;
    if (pessoa.dieta == Dieta.semPorco) semPorco++;
    if (pessoa.bebe == true) bebem++;
    if (pessoa.bebe == false) abstemios++;
  }

  return EfeitosDasPreferencias(
    veggies: veggies,
    semPorco: semPorco,
    bebem: bebem,
    adultosQueBebem: math.max(0, adultos - abstemios),
  );
}

/// O resumo agregado de RN-21, com a copy literal da regra.
///
/// `A lista já se ajusta às preferências: {n} veggie 🥗 · {n} sem porco 🚫 ·
/// {n} bebem 🍺` — **omitindo os termos zerados**, como RN-21 manda.
///
/// Quando os três estão zerados não sobra termo nenhum e o resumo é a string
/// vazia: RN-21 define a omissão mas não o que dizer quando não há nada a
/// dizer, e uma frase com dois-pontos e nada depois seria pior que silêncio.
/// Default declarado desta camada, não texto da spec.
String resumoDasPreferencias(EfeitosDasPreferencias efeitos) {
  final termos = <String>[
    if (efeitos.veggies > 0) '${efeitos.veggies} veggie 🥗',
    if (efeitos.semPorco > 0) '${efeitos.semPorco} sem porco 🚫',
    if (efeitos.bebem > 0) '${efeitos.bebem} bebem 🍺',
  ];

  if (termos.isEmpty) return '';

  return 'A lista já se ajusta às preferências: ${termos.join(' · ')}';
}
