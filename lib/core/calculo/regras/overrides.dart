import 'dart:math' as math;

import '../dominio/catalogo_de_itens.dart';
import '../dominio/chave_item.dart';
import '../dominio/item_de_lista.dart';

/// O passo do stepper de preço, em reais — e também o mínimo (RN-12).
const double _passoDePreco = 1;

/// Ajusta a quantidade de [item] em [passos] passos — RN-12 · CALC-17.
///
/// O passo é o do catálogo: 0,5 kg nas carnes, 2 latas na cerveja, 1 nos
/// demais. [passos] negativo desce, e o mínimo é **um passo** — a carne para
/// em 0,5 kg, a cerveja em 2 latas, os demais em 1. Nunca zero: quem tira o
/// item da lista é a seleção, não o stepper.
///
/// O ajuste **cobre** o valor automático sem apagá-lo, para que [restaurado]
/// tenha ao que voltar.
ItemDeLista comPassoDeQuantidade(ItemDeLista item, int passos) {
  final passo = catalogoDeItens[item.chave]!.passoDeQuantidade;

  return item.copyWith(
    quantidadeOverride: math.max(passo, item.quantidade + passos * passo),
  );
}

/// Ajusta o preço de [item] em [passos] passos de R$ 1 — RN-12 · CALC-17.
///
/// O mínimo é **R$ 1**: item de graça não existe na lista.
ItemDeLista comPassoDePreco(ItemDeLista item, int passos) => item.copyWith(
      precoOverride: math.max(
        _passoDePreco,
        item.preco + passos * _passoDePreco,
      ),
    );

/// Desfaz os dois ajustes manuais de [item] — o "RESTAURAR" de RN-12 ·
/// CALC-17.
///
/// O item volta **exatamente** ao valor automático, e deixa de se declarar
/// editado.
///
/// ⚠️ Construído pelo construtor, **nunca** por `copyWith`: o `copyWith` de
/// `ItemDeLista` resolve cada campo com `?? this.x`, então passar `null` nos
/// overrides mantém o que estava e o RESTAURAR não apagaria nada. O resto do
/// item — quem leva, carrinho — sobrevive: restaurar zera os **dois
/// overrides**, não o item.
ItemDeLista restaurado(ItemDeLista item) => ItemDeLista(
      chave: item.chave,
      nome: item.nome,
      emoji: item.emoji,
      unidade: item.unidade,
      quantidadeAutomatica: item.quantidadeAutomatica,
      precoBase: item.precoBase,
      essencial: item.essencial,
      fonteDaProporcao: item.fonteDaProporcao,
      quemLeva: item.quemLeva,
      noCarrinho: item.noCarrinho,
    );

/// O mapa de ajustes do "RESTAURAR" global de RN-12: nenhum — CALC-17.
///
/// Recalcular a composição com ele devolve a lista automática inteira.
Map<ChaveItem, OverrideDeItem> semOverrides() => const {};
