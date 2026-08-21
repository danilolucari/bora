/// O corredor de mercado em que um item é encontrado — RN-11 · CALC-24.
///
/// Existe só como **atributo** de `PrecoDeMercado`: é o dado que a tabela de
/// RN-11 declara para os seus oito itens, e nada além disso.
///
/// A **ordem** em que o modo COMPRAR agrupa os corredores (RN-27: AÇOUGUE →
/// HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA) é da spec `lista`, dona de
/// RN-27 — nada aqui depende do `index` destes valores. O corredor dos itens
/// que RN-11 **não** declara (água, sal, copos, destilados…) também é decisão
/// de `lista`: atribuí-lo aqui seria fabricação (A-17).
enum Corredor {
  acougue,
  hortifruti,
  padaria,
  bebidas,
  mercearia,
}
