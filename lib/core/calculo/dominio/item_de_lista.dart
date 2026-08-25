import 'chave_item.dart';

/// Um item já calculado da lista da festa (CALC-05, CALC-17).
///
/// Guarda **as duas verdades ao mesmo tempo**: o que a calculadora decidiu
/// ([quantidadeAutomatica], [precoBase]) e o que o anfitrião ajustou à mão
/// ([quantidadeOverride], [precoOverride]). É o que permite a RN-12 restaurar
/// o valor automático **exato** depois de qualquer edição — o automático nunca
/// é sobrescrito, só coberto.
///
/// Valor imutável, com `==`/`hashCode` escritos à mão (A-19).
class ItemDeLista {
  const ItemDeLista({
    required this.chave,
    required this.nome,
    required this.emoji,
    required this.unidade,
    required this.quantidadeAutomatica,
    required this.precoBase,
    this.quantidadeOverride,
    this.precoOverride,
    this.essencial = false,
    this.fonteDaProporcao,
    this.quemLeva,
    this.noCarrinho = false,
  });

  final ChaveItem chave;
  final String nome;
  final String emoji;
  final UnidadeDeItem unidade;

  /// O que RN-03..RN-10 calcularam para este item.
  final double quantidadeAutomatica;

  /// O preço-base do catálogo da calculadora (RN-03..RN-10).
  final double precoBase;

  /// Ajuste manual de quantidade (RN-12); `null` = sem ajuste.
  final double? quantidadeOverride;

  /// Ajuste manual de preço (RN-12); `null` = sem ajuste.
  final double? precoOverride;

  /// `true` nos quatro itens de RN-10, que entram na lista sozinhos.
  final bool essencial;

  /// A fonte do badge `AUTO ∝ <fonte>` de RN-10.
  final String? fonteDaProporcao;

  /// Quem se ofereceu para levar o item — é o **nome** da pessoa, porque
  /// `Pessoa` não tem identificador nesta camada (A-24).
  final String? quemLeva;

  /// Estado do modo COMPRAR da tela Lista.
  ///
  /// Mora aqui só porque o arquivo 01 §6 declara o campo no próprio item; o
  /// comportamento de marcar e desmarcar é da spec `lista`, não desta camada.
  final bool noCarrinho;

  /// A quantidade que vale: o ajuste manual, quando existe (RN-12).
  double get quantidade => quantidadeOverride ?? quantidadeAutomatica;

  /// O preço que vale: o ajuste manual, quando existe (RN-12).
  double get preco => precoOverride ?? precoBase;

  /// `quantidade × preço`, **sem arredondar** — dinheiro só arredonda na
  /// formatação (RN-13). O Frango de 1,2 kg vale 21,60 aqui, não 22.
  double get valor => quantidade * preco;

  /// `true` quando há qualquer ajuste manual — é o ponto vermelho de RN-12.
  bool get editado => quantidadeOverride != null || precoOverride != null;

  /// Copia trocando campos. **Não zera override**: `null` significa "mantém o
  /// que estava". Quem apaga um ajuste é o restaurar de RN-12.
  ItemDeLista copyWith({
    ChaveItem? chave,
    String? nome,
    String? emoji,
    UnidadeDeItem? unidade,
    double? quantidadeAutomatica,
    double? precoBase,
    double? quantidadeOverride,
    double? precoOverride,
    bool? essencial,
    String? fonteDaProporcao,
    String? quemLeva,
    bool? noCarrinho,
  }) =>
      ItemDeLista(
        chave: chave ?? this.chave,
        nome: nome ?? this.nome,
        emoji: emoji ?? this.emoji,
        unidade: unidade ?? this.unidade,
        quantidadeAutomatica: quantidadeAutomatica ?? this.quantidadeAutomatica,
        precoBase: precoBase ?? this.precoBase,
        quantidadeOverride: quantidadeOverride ?? this.quantidadeOverride,
        precoOverride: precoOverride ?? this.precoOverride,
        essencial: essencial ?? this.essencial,
        fonteDaProporcao: fonteDaProporcao ?? this.fonteDaProporcao,
        quemLeva: quemLeva ?? this.quemLeva,
        noCarrinho: noCarrinho ?? this.noCarrinho,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemDeLista &&
          other.chave == chave &&
          other.nome == nome &&
          other.emoji == emoji &&
          other.unidade == unidade &&
          other.quantidadeAutomatica == quantidadeAutomatica &&
          other.precoBase == precoBase &&
          other.quantidadeOverride == quantidadeOverride &&
          other.precoOverride == precoOverride &&
          other.essencial == essencial &&
          other.fonteDaProporcao == fonteDaProporcao &&
          other.quemLeva == quemLeva &&
          other.noCarrinho == noCarrinho;

  @override
  int get hashCode => Object.hash(
        chave,
        nome,
        emoji,
        unidade,
        quantidadeAutomatica,
        precoBase,
        quantidadeOverride,
        precoOverride,
        essencial,
        fonteDaProporcao,
        quemLeva,
        noCarrinho,
      );
}

/// O ajuste manual que a feature guarda por item (RN-12 · CALC-17).
///
/// `null` em qualquer um dos dois campos significa **sem ajuste** naquele
/// eixo — o item usa o valor automático.
class OverrideDeItem {
  const OverrideDeItem({this.quantidade, this.preco});

  final double? quantidade;
  final double? preco;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverrideDeItem &&
          other.quantidade == quantidade &&
          other.preco == preco;

  @override
  int get hashCode => Object.hash(quantidade, preco);
}
