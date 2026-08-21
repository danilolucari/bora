import '../dominio/catalogo_de_itens.dart';
import '../dominio/chave_item.dart';
import '../dominio/composicao_da_festa.dart';
import '../dominio/contagem_de_pessoas.dart';
import '../dominio/item_de_lista.dart';
import 'essenciais.dart';
import 'fator_duracao.dart';
import 'preferencias.dart';
import 'quantidade_de_carne.dart';
import 'quantidade_de_cerveja.dart';
import 'quantidade_de_destilado.dart';
import 'quantidades_de_bebida.dart';
import 'quantidades_por_pessoa.dart';
import 'totais.dart';

/// As três carnes de RN-03 — as únicas que dividem as gramas entre si.
const Set<ChaveItem> _carnes = {
  ChaveItem.bovina,
  ChaveItem.suina,
  ChaveItem.frango,
};

/// Os três destilados de RN-09 — os 120 ml por adulto se dividem entre eles.
const Set<ChaveItem> _destilados = {
  ChaveItem.vodka,
  ChaveItem.cachaca,
  ChaveItem.whisky,
};

/// A lista da festa já calculada — CALC-15, CALC-16.
///
/// [itens] são os que o anfitrião escolheu (mais o kit que RN-21 acrescenta);
/// [essenciais] são os quatro de RN-10, que entram sozinhos. A separação não é
/// cosmética: a tela mostra os essenciais em categoria própria, e o total do
/// exemplo canônico soma os dois grupos com regras diferentes.
class ResultadoDoCalculo {
  const ResultadoDoCalculo({
    required this.itens,
    required this.essenciais,
    required this.contagem,
    required this.fator,
    required this.totalDosItens,
    required this.totalDosEssenciais,
    required this.porCabeca,
    required this.porAdulto,
  });

  final List<ItemDeLista> itens;
  final List<ItemDeLista> essenciais;
  final ContagemDePessoas contagem;

  /// O fator de RN-02 usado no cálculo.
  final double fator;

  /// A soma exata dos itens escolhidos — o "SAI POR" da tela Montar.
  ///
  /// Estado padrão: 210,60, que RN-13 exibe como **R$ 211**.
  final double totalDosItens;

  /// A soma dos essenciais que entram no total (A-01/A-02): 60,00.
  final double totalDosEssenciais;

  /// A estimativa "≈ R$ X / cabeça" da tela Montar: total **sem** essenciais
  /// dividido por **pessoas**, criança inclusive (210,60 ÷ 7 → ≈ R$ 30).
  final double porCabeca;

  /// O "por adulto" da tela Lista: total **com** essenciais dividido por
  /// **adultos**, criança de fora (270,60 ÷ 6 → ≈ R$ 45) — RN-14.
  final double porAdulto;

  /// O total da festa com os essenciais que somam: 270,60 no estado padrão,
  /// exibido como **R$ 271**.
  double get totalComEssenciais => totalDosItens + totalDosEssenciais;

  /// A lista inteira, na ordem em que ela aparece: escolhidos e depois os
  /// essenciais de RN-10.
  List<ItemDeLista> get todosOsItens => [...itens, ...essenciais];

  /// `true` quando há pelo menos um item ajustado à mão — é o que acende o
  /// "RESTAURAR" de RN-12.
  bool get temOverrides => todosOsItens.any((item) => item.editado);
}

/// O orquestrador: o **único** lugar onde as regras de cálculo se encontram —
/// CALC-15, CALC-16.
///
/// Nenhuma tela recalcula nada; todas consomem [calcular].
abstract final class CalculadoraDaFesta {
  /// Monta a lista da festa a partir da composição.
  ///
  /// A ordem dos passos é determinística e **importa**:
  ///
  /// 1. a guarda de `pessoas == 0` vem **antes** de tudo (A-11): festa sem
  ///    ninguém tem lista vazia, e nenhum piso `max(1, …)` de RN-04..RN-09
  ///    chega a rodar — senão uma festa sem plateia compraria uma lata de
  ///    cerveja (UC-03 E1);
  /// 2. o fator de duração de RN-02;
  /// 3. as preferências de RN-21, que **mudam a seleção**: tiram a suína e
  ///    acrescentam o kit veggie;
  /// 4. as gramas de carne divididas entre as carnes **restantes** — depois da
  ///    remoção da suína, nunca antes;
  /// 5. a quantidade de cada item selecionado, percorrendo a ordem canônica do
  ///    catálogo; quantidade 0 ⇒ o item **não entra** na lista;
  /// 6. os ajustes manuais de RN-12, cobrindo o valor automático sem apagá-lo;
  /// 7. os quatro essenciais de RN-10, que entram sozinhos.
  static ResultadoDoCalculo calcular(ComposicaoDaFesta composicao) {
    final contagem = composicao.contagem;
    final fator = fatorDuracao(composicao.duracaoHoras);

    if (contagem.pessoas == 0) {
      return ResultadoDoCalculo(
        itens: const [],
        essenciais: const [],
        contagem: contagem,
        fator: fator,
        totalDosItens: 0,
        totalDosEssenciais: 0,
        porCabeca: 0,
        porAdulto: 0,
      );
    }

    final efeitos = efeitosDasPreferencias(
      pessoas: composicao.pessoas,
      adultos: contagem.adultos,
    );
    final selecionados = _selecaoAjustada(composicao.itensSelecionados, efeitos);

    final kgDeCadaCarne = kgPorCarne(
      gramasTotais: gramasDeCarne(contagem: contagem, fator: fator),
      carnesSelecionadas: _carnes.where(selecionados.contains).length,
    );
    final destiladosSelecionados = _destilados.where(selecionados.contains).length;

    final itens = <ItemDeLista>[];

    for (final chave in ordemCanonicaDaLista) {
      if (!selecionados.contains(chave)) continue;

      final quantidade = _quantidadeDe(
        chave,
        contagem: contagem,
        fator: fator,
        kgDeCadaCarne: kgDeCadaCarne,
        destiladosSelecionados: destiladosSelecionados,
        adultosQueBebem: efeitos.adultosQueBebem,
      );

      if (quantidade == 0) continue;

      itens.add(
        _itemDe(catalogoDeItens[chave]!, quantidade, composicao.overrides[chave]),
      );
    }

    final essenciais = essenciaisAutomaticos();
    final somaDosItens = totalExato(itens);
    final somaDosEssenciais = totalDosEssenciais(essenciais);

    return ResultadoDoCalculo(
      itens: itens,
      essenciais: essenciais,
      contagem: contagem,
      fator: fator,
      totalDosItens: somaDosItens,
      totalDosEssenciais: somaDosEssenciais,
      porCabeca: estimativaPorCabeca(
        totalDosItens: somaDosItens,
        pessoas: contagem.pessoas,
      ),
      porAdulto: estimativaPorAdulto(
        totalComEssenciais: somaDosItens + somaDosEssenciais,
        adultos: contagem.adultos,
      ),
    );
  }
}

/// A seleção depois de RN-21: sem a suína quando alguém não come porco, com o
/// kit de legumes quando há ao menos uma pessoa veggie.
Set<ChaveItem> _selecaoAjustada(
  Set<ChaveItem> selecionados,
  EfeitosDasPreferencias efeitos,
) {
  final ajustada = {...selecionados};

  if (efeitos.removerSuina) ajustada.remove(ChaveItem.suina);
  if (efeitos.incluirKitVeggie) ajustada.add(ChaveItem.legumesParaGrelha);

  return ajustada;
}

/// A quantidade automática de um item selecionado, pela regra que o governa.
double _quantidadeDe(
  ChaveItem chave, {
  required ContagemDePessoas contagem,
  required double fator,
  required double kgDeCadaCarne,
  required int destiladosSelecionados,
  required int adultosQueBebem,
}) =>
    switch (chave) {
      ChaveItem.bovina ||
      ChaveItem.suina ||
      ChaveItem.frango =>
        kgDeCadaCarne,
      ChaveItem.paoDeAlho => unidadesDePaoDeAlho(
          pessoas: contagem.pessoas,
          fator: fator,
        ).toDouble(),
      ChaveItem.refrigerante => garrafasDeRefrigerante(
          adultos: contagem.adultos,
          criancas: contagem.criancas,
          fator: fator,
        ).toDouble(),
      ChaveItem.suco => litrosDeSuco(
          adultos: contagem.adultos,
          criancas: contagem.criancas,
          fator: fator,
        ).toDouble(),
      ChaveItem.agua => garrafasDeAgua(
          pessoas: contagem.pessoas,
          fator: fator,
        ).toDouble(),
      // RN-21 substitui os `adultos` de RN-05 por quem bebe (A-06).
      ChaveItem.cerveja => latasDeCerveja(
          adultosQueBebem: adultosQueBebem,
          fator: fator,
        ).toDouble(),
      ChaveItem.vodka || ChaveItem.cachaca || ChaveItem.whisky =>
        garrafasPorDestilado(
          adultos: contagem.adultos,
          fator: fator,
          destiladosSelecionados: destiladosSelecionados,
        ).toDouble(),
      // O kit de RN-21 é um, e não escala com a duração (A-10).
      ChaveItem.legumesParaGrelha =>
        catalogoDeItens[ChaveItem.legumesParaGrelha]!.quantidadeDefault!,
      // Os quatro de RN-10 entram sozinhos, por `essenciaisAutomaticos()`, e
      // por isso nunca saem daqui — nem se alguém os marcar como chip.
      ChaveItem.carvao ||
      ChaveItem.gelo ||
      ChaveItem.salGrosso ||
      ChaveItem.coposEPratos =>
        0,
    };

/// Transforma a definição de catálogo no item calculado, com o ajuste manual
/// de RN-12 **cobrindo** o valor automático — que continua guardado.
ItemDeLista _itemDe(
  DefinicaoDeItem definicao,
  double quantidade,
  OverrideDeItem? override,
) =>
    ItemDeLista(
      chave: definicao.chave,
      nome: definicao.nome,
      emoji: definicao.emoji,
      unidade: definicao.unidade,
      quantidadeAutomatica: quantidade,
      precoBase: definicao.precoBase,
      quantidadeOverride: override?.quantidade,
      precoOverride: override?.preco,
      essencial: definicao.essencial,
      fonteDaProporcao: definicao.fonteDaProporcao,
    );
