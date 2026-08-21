import 'dart:math' as math;

/// As primitivas numéricas de que **toda** regra desta camada depende.
///
/// A política de precisão do projeto, em uma frase: a aritmética interna é
/// `double` em reais, **sem arredondamento intermediário**; dinheiro arredonda
/// uma única vez, na formatação (RN-13); e total é o arredondamento da soma
/// exata, nunca a soma de parcelas já arredondadas.
///
/// Nenhum outro arquivo da camada escreve `0.01`, o `100` do arredondamento de
/// quantidade ou um `.round()` de quantidade — tudo passa por aqui.

/// Arredonda [gramas] para o décimo de quilo mais próximo, devolvendo **kg**
/// (RN-03 · CALC-07).
///
/// ⚠️ O arredondamento acontece **em gramas**, nunca em kg. Em kg a conta
/// natural — `(1.15 * 10).round() / 10` — devolve **1,1**, porque o binário
/// guarda 1,15 como 1,14999…, e `(1.15 * 10)` vira 11,499…, que arredonda para
/// 11. Isso daria Bovina a R$ 49,50 e **quebraria o caso literal de R$ 211**
/// (risco R-1). Em gramas, `1150 / 100` é exatamente 11,5, que arredonda para
/// 12 → 1,2 kg.
double kgArredondadoEmDecimos(double gramas) => (gramas / 100).round() / 10;

/// Converte uma quantidade bruta em unidades inteiras com piso de 1
/// (RN-04..RN-09).
///
/// O `ceil` é **regra de negócio**, não formatação: não dá para comprar meia
/// lata. O piso de 1 vale quando há plateia — quem decide que uma festa sem
/// ninguém não compra nada é a guarda de `pessoas == 0` do orquestrador (A-11).
int unidadesComPisoDeUm(double bruto) => math.max(1, bruto.ceil());

/// Tolerância de 1 centavo de RN-16.
///
/// Vive na **aritmética**: resíduo de crédito ou de dívida até este valor conta
/// como zero e não gera linha de acerto. A exibição continua inteira, por
/// RN-13 — as duas convivem em camadas diferentes (A-13).
const double toleranciaDeCentavo = 0.01;

/// `true` quando [valor] é zero dentro da [toleranciaDeCentavo], nos dois
/// sentidos — crédito ou dívida.
bool ehZeroNaTolerancia(double valor) => valor.abs() <= toleranciaDeCentavo;
