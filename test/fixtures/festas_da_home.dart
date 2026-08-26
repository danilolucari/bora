/// As festas como a **Home** as vê — a semente dos testes da spec 04.
///
/// Duas fontes, deliberadamente separadas:
///
/// 1. **A festa que está chegando é RN-30**, e vem *lida* de
///    `rn30_estado_inicial.dart` — nome, data, local, e os contadores
///    `confirmadosNaHome`/`pendentesNaHome`. Nada é redigitado aqui: repetir
///    os literais criaria uma segunda fonte, e as duas divergiriam no
///    primeiro ajuste.
/// 2. **As duas festas passadas são A-04**, não RN-30. Por isso não entram no
///    arquivo bruto de RN-30, cujo doc declara "fonte literal: RN-30" — pôr
///    festa passada lá tornaria aquela declaração falsa. O bruto fica
///    **intocado**, que é o que E-1 protege.
///
/// Dentro das passadas, o que é literal e o que é premissa também está
/// separado: de UC-24 vêm **só** "Churras da laje", "14 pessoas" e "R$ 612".
/// Data, hora, local, duração e emoji **não são literais de spec** — UC-24 não
/// os define. A segunda festa inteira **não é literal de spec**: existe porque
/// T-02 diz "2 passadas" e W-02 desenha a seção ARQUIVO, e sem ela o aceite
/// ficaria sem dado (L-002: não afirmar como literal o que a spec não define).
library;

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';

import 'rn30_estado_inicial.dart';
import 'rn30_estado_inicial_tipado.dart';

/// "Churras da laje · 14 pessoas · R$ 612" — o literal de UC-24.
///
/// `nome`, `pessoas` e `total` são da spec. O resto é premissa A-04.
const Map<String, Object?> churrasDaLajeUc24 = {
  'id': 'laje21jun',
  'nome': 'Churras da laje',
  'pessoas': 14,
  'total': 612.0,
  // A-04 — UC-24 não define nada abaixo desta linha.
  'data': 'SÁB · 21 JUN',
  'hora': '13H',
  'local': 'Laje do Rafa — Vila Madalena',
  'duracaoHoras': 4,
};

/// A segunda festa passada — **não é literal de spec**, é premissa A-04.
///
/// Existe porque T-02 diz "2 passadas": com uma só, o subtítulo derivado
/// nunca produziria a string de T-02 e o ARQUIVO teria uma linha só.
const Map<String, Object?> segundaFestaPassadaA04 = {
  'id': 'fimdeano20dez',
  'nome': 'Churras de fim de ano',
  'pessoas': 9,
  'total': 430.0,
  'data': 'SÁB · 20 DEZ',
  'hora': '15H',
  'local': 'Quintal da Bia',
  'duracaoHoras': 6,
};

/// As iniciais dos avatares de T-02 — "R/A/L".
///
/// **Derivadas** dos confirmados de RN-30, na ordem do bruto, e não
/// redigitadas: se a fixture mudar de gente, o avatar acompanha.
final List<String> iniciaisDosConfirmadosRn30 = [
  for (final pessoa in pessoasRn30)
    if (pessoa['status'] == 'confirmado') (pessoa['nome']! as String)[0],
].take(3).toList();

/// O id da festa de RN-30 — o `rafa18` do link `bora.app/c/rafa18` (RN-24),
/// que é o único identificador que a spec dá a esta festa.
const String idDaFestaRn30 = 'rafa18';

/// A festa de RN-30 como a Home a mostra: 4 confirmados · 2 pendentes.
final ResumoDeFesta rn30NaHome = ResumoDeFesta(
  id: idDaFestaRn30,
  festa: festaRn30Tipada,
  confirmados: festaRn30['confirmadosNaHome']! as int,
  pendentes: festaRn30['pendentesNaHome']! as int,
  iniciais: iniciaisDosConfirmadosRn30,
);

/// As duas festas concluídas do ARQUIVO (UC-24), na ordem de exibição.
final List<ResumoDeFesta> festasPassadas = [
  _passadaDe(churrasDaLajeUc24),
  _passadaDe(segundaFestaPassadaA04),
];

/// O estado inteiro da Home: uma festa chegando e duas passadas — o que faz o
/// subtítulo derivado de T-02 ler "1 festa chegando · 2 passadas".
final List<ResumoDeFesta> festasDaHome = [rn30NaHome, ...festasPassadas];

ResumoDeFesta _passadaDe(Map<String, Object?> bruta) => ResumoDeFesta(
      id: bruta['id']! as String,
      festa: Festa(
        nome: bruta['nome']! as String,
        data: bruta['data']! as String,
        hora: bruta['hora']! as String,
        local: bruta['local']! as String,
        duracaoHoras: bruta['duracaoHoras']! as int,
        status: StatusDaFesta.passada,
      ),
      pessoas: bruta['pessoas']! as int,
      total: bruta['total']! as double,
    );
