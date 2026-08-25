/// Igualdade profunda para as coleções das entidades de domínio — CALC-05.
///
/// `==` de `List`, `Set` e `Map` em Dart é **identidade**: duas listas com os
/// mesmos elementos são diferentes. Como `spec.md` P1-2 AC2 exige que entidade
/// com os mesmos campos seja igual, uma entidade que carrega coleção precisa
/// comparar o conteúdo.
///
/// Os comparadores são escritos à mão porque as duas saídas prontas estão
/// fechadas: `package:collection` é dependência nova, que A-19 proíbe
/// (dispararia `depend_on_referenced_packages` e quebraria o `flutter
/// analyze`), e `flutter/foundation` está fora porque esta camada é Dart puro
/// (CALC-27).
library;

/// Se [a] e [b] têm os mesmos elementos **na mesma ordem**.
bool listaIgual<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Se [a] e [b] têm os mesmos elementos, em qualquer ordem.
bool conjuntoIgual<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  return a.length == b.length && a.containsAll(b);
}

/// Se [a] e [b] têm as mesmas chaves, cada uma com o mesmo valor.
bool mapaIgual<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entrada in a.entries) {
    if (!b.containsKey(entrada.key)) return false;
    if (b[entrada.key] != entrada.value) return false;
  }
  return true;
}

/// O hash de [mapa], independente da ordem de inserção.
///
/// Existe porque `Object.hashAllUnordered` recebe um iterável de valores, e um
/// mapa precisa que chave e valor entrem **juntos** — senão `{a: 1, b: 2}` e
/// `{a: 2, b: 1}` colidiriam.
int hashDeMapa<K, V>(Map<K, V> mapa) => Object.hashAllUnordered(
      [for (final entrada in mapa.entries) Object.hash(entrada.key, entrada.value)],
    );
