/// O corredor de mercado em que um item é encontrado — RN-11 · RN-27 ·
/// CALC-24.
///
/// É atributo de **duas** declarações do mesmo fato: `PrecoDeMercado.corredor`
/// (a tabela de RN-11, para as suas oito linhas) e `DefinicaoDeItem.corredor`
/// (o catálogo da calculadora, para os seus dezesseis itens). O catálogo é a
/// fonte para agrupar a lista da festa — inclusive para água, suco, sal,
/// copos e destilados, que RN-11 não cobre — e um teste de coerência impede
/// que as duas divirjam nas oito chaves comuns.
///
/// A **ordem** em que o modo COMPRAR agrupa os corredores (RN-27: AÇOUGUE →
/// HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA) é da spec `lista`, dona de
/// RN-27 — nada aqui depende do `index` destes valores.
enum Corredor {
  acougue,
  hortifruti,
  padaria,
  bebidas,
  mercearia,
}
