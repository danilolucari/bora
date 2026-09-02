import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/chave_de_pessoa.dart';
import '../galera_textos.dart';
import 'botao_de_dieta.dart';

/// O painel expandido de uma pessoa, em T-05: "para o anfitrião, só a nota
/// '👑 Anfitrião manda em tudo — acesso fixo.'; para os demais, 'NÍVEL DE
/// ACESSO' (3 botões, ativo preto), 'RESTRIÇÃO ALIMENTAR' (🍖/🥗/🚫, ativo
/// vermelho) e 'BEBIDA' (toggle BEBE 🍺 ✓ / NÃO BEBE 🚫, ativo preto)".
///
/// **O ramo do anfitrião não desabilita, ele omite** (GAL-16): as três seções
/// não estão na árvore. Controle desabilitado ainda é controle — some com um
/// `enabled` esquecido, e a defesa de RN-22 vira aparência.
///
/// **`ANFITRIÃO` não é oferecido em lugar nenhum** (GAL-18): a lista de papéis
/// vem de [GaleraTextos.papeisAtribuiveis], que não o contém. Não há caminho
/// de tela que atribua o papel do dono.
///
/// **Por que não `BoraExpandableRow`**: dele vêm só as constantes — a
/// espessura da borda do painel —, pelo motivo que `design.md` §2.3 registra.
class PainelDaPessoa extends StatelessWidget {
  const PainelDaPessoa({
    required this.chave,
    required this.pessoa,
    required this.onEscolherPapel,
    required this.onEscolherDieta,
    required this.onAlternarBebida,
    this.podeGerenciarPapeis = true,
    super.key,
  });

  /// O índice que o [BoraSegmentedControl] entende como "nenhum ativo".
  ///
  /// É o estado de quem **não declarou** bebida (A-14): §5 pede exatamente um
  /// ativo entre opções, e acender uma metade do toggle antes do primeiro
  /// toque afirmaria uma declaração que a pessoa não fez.
  static const int nenhumAtivo = -1;

  /// O vão entre uma seção e a seguinte — o ritmo vertical de §5.
  static double get vaoEntreBlocos => BoraSpacing.linhaLista.top;

  /// O endereço estável da linha — vai em toda escrita emitida daqui.
  final ChaveDePessoa chave;

  final Pessoa pessoa;

  /// Emitido com o papel escolhido — nunca com o que já está ativo (GAL-28).
  final void Function(ChaveDePessoa chave, PapelNaFesta papel) onEscolherPapel;

  /// Emitido com a dieta escolhida — RN-21.
  final void Function(ChaveDePessoa chave, Dieta dieta) onEscolherDieta;

  /// Emitido com o valor **desejado** da bebida, não com "inverta o que
  /// estiver lá": quem toca já sabe qual metade do toggle tocou.
  final void Function(ChaveDePessoa chave, bool bebe) onAlternarBebida;

  /// GAL-27 AC2: sem a capacidade de gerenciar papéis, "NÍVEL DE ACESSO" some
  /// da árvore em **todos** os painéis. Dieta e bebida ficam — UC-11 dá o ator
  /// como "anfitrião/co-anfitrião".
  final bool podeGerenciarPapeis;

  /// GAL-16: o anfitrião não tem controle nenhum, só a nota.
  bool get _ehAnfitriao => pessoa.papel == PapelNaFesta.anfitriao;

  int get _indiceDoPapel => GaleraTextos.papeisAtribuiveis.indexOf(pessoa.papel);

  /// `0` bebe, `1` não bebe, [nenhumAtivo] não declarado.
  int get _indiceDaBebida => switch (pessoa.bebe) {
        true => 0,
        false => 1,
        null => nenhumAtivo,
      };

  void _selecionarPapel(int indice) {
    // GAL-28: tocar a opção já ativa não muda estado nem emite escrita.
    if (indice == _indiceDoPapel) return;
    onEscolherPapel(chave, GaleraTextos.papeisAtribuiveis[indice]);
  }

  void _selecionarBebida(int indice) {
    if (indice == _indiceDaBebida) return;
    onAlternarBebida(chave, indice == 0);
  }

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      // §5: "painel aberto com fundo `paper` e `border-top 2px`".
      fundo: BoraColors.paper,
      larguraDaBorda: BoraExpandableRow.espessuraDaBordaDoPainel,
      padding: BoraSpacing.linhaLista,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _ehAnfitriao ? _doAnfitriao() : _dosDemais(),
      ),
    );
  }

  /// GAL-16: **só** a nota 👑. Nenhum controle, nem desabilitado.
  List<Widget> _doAnfitriao() => [
        Text(GaleraTextos.notaDoAnfitriao, style: BoraTextStyles.dica),
      ];

  List<Widget> _dosDemais() => [
        if (podeGerenciarPapeis) ...[
          _Secao(GaleraTextos.secaoNivelDeAcesso),
          BoraSegmentedControl(
            opcoes: GaleraTextos.papeis,
            indiceAtivo: _indiceDoPapel,
            onSelecionar: _selecionarPapel,
          ),
          SizedBox(height: vaoEntreBlocos),
        ],
        _Secao(GaleraTextos.secaoRestricao),
        Row(
          children: [
            for (final dieta in Dieta.values) ...[
              if (dieta != Dieta.values.first) SizedBox(width: vaoEntreBlocos),
              Expanded(
                child: BotaoDeDieta(
                  dieta: dieta,
                  ativo: pessoa.dieta == dieta,
                  onEscolher: (escolhida) => onEscolherDieta(chave, escolhida),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: vaoEntreBlocos),
        _Secao(GaleraTextos.secaoBebida),
        BoraSegmentedControl(
          opcoes: const [GaleraTextos.bebe, GaleraTextos.naoBebe],
          indiceAtivo: _indiceDaBebida,
          onSelecionar: _selecionarBebida,
        ),
      ];
}

/// O rótulo de uma seção do painel, no papel "label de seção" de §2.
class _Secao extends StatelessWidget {
  const _Secao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BoraSpacing.tag.top),
      child: Text(texto, style: BoraTextStyles.labelSecao),
    );
  }
}
