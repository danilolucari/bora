import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';

import '../fixtures/rn30_estado_inicial_tipado.dart';

/// O `festaId` que os testes da Galera usam — o mesmo endereço em toda a
/// suíte, para que a asserção "escreveu na festa certa" tenha com o que
/// discriminar.
const String idDaFestaDeTeste = 'festa-1';

/// Uma [GaleraDaFesta] de teste, semeada pela fixture de RN-30 e ajustável
/// campo a campo.
///
/// Derivada da fixture, nunca copiada: os literais de RN-30 continuam morando
/// num lugar só (`rn30_estado_inicial.dart`).
GaleraDaFesta galeraDeTeste({
  String festaId = idDaFestaDeTeste,
  ConviteDaFesta? convite,
  List<Pessoa>? pessoas,
}) =>
    GaleraDaFesta(
      festaId: festaId,
      convite: convite ?? conviteRn30Tipado,
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        pessoas: pessoas ?? pessoasRn30Tipadas,
        itensSelecionados: itensPadraoRn30Tipados.toSet(),
      ),
    );

/// Uma pessoa qualquer, para os casos em que o teste precisa mexer na lista
/// sem depender de quem exatamente é.
Pessoa pessoaDeTeste(
  String nome, {
  PapelNaFesta papel = PapelNaFesta.convidado,
  StatusDePresenca status = StatusDePresenca.confirmado,
  Dieta? dieta,
  bool? bebe,
}) =>
    Pessoa(
      nome: nome,
      papel: papel,
      status: status,
      dieta: dieta,
      bebe: bebe,
    );
