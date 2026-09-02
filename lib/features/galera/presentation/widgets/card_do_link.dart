import 'package:flutter/widgets.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/festas/festas.dart';
import '../galera_textos.dart';

/// O card do link de T-05: "escuro, sombra roxa; label amarela 'LINK PRA
/// CONVIDAR'; `bora.app/c/rafa18` sublinhado + botão claro 'COPIAR 🔗'; label
/// 'QUEM ABRIR O LINK PODE…'; segmented creme SÓ VER / EDITAR LISTA /
/// CO-ANFITRIÃO; nota dinâmica do nível (RN-23)".
///
/// **Composto, nunca estendido**: [BoraSurface] dá o fundo `ink` e a sombra
/// dura roxa, [BoraSegmentedControl] dá os três níveis na variante de card
/// escuro e [BoraSecondaryButton] dá o botão claro. Nenhuma cor, fonte ou
/// sombra é escrita aqui — só tokens.
///
/// **O botão é de fundo branco de propósito.** Sobre o card escuro, o
/// secundário transparente com texto `ink` seria um retângulo ilegível; §5 dá
/// as duas variantes e T-05 pede a clara.
class CardDoLink extends StatelessWidget {
  const CardDoLink({
    required this.convite,
    required this.onCopiar,
    required this.onEscolherNivel,
    this.podeConfigurarNivel = true,
    super.key,
  });

  /// §4, card do link (galera): `5px 5px 0 #6C4BF5`.
  ///
  /// Lê o token em vez de repetir o `5`, pelo mesmo motivo de
  /// [BoraHeroCard.deslocamentoDaSombra]: com dois números separados, mudar o
  /// token não mudaria o card.
  static final double deslocamentoDaSombra = BoraShadows.cardLink.offset.dx;

  /// O vão entre um bloco do card e o seguinte — o ritmo vertical de §5.
  static double get vaoEntreBlocos => BoraSpacing.linhaLista.top;

  /// A cor de todo texto próprio do card: §1, "`cream` — texto sobre `ink`".
  static const Color corDoTexto = BoraColors.cream;

  /// O código do link e o nível de quem abrir — RN-23.
  final ConviteDaFesta convite;

  /// Emitido pelo "COPIAR 🔗". Quem monta a URL copiada é o bloc, a partir da
  /// festa corrente (GAL-03).
  final VoidCallback onCopiar;

  /// Emitido com o nível tocado — **nunca** com o que já está ativo (GAL-28).
  final ValueChanged<NivelDoLink> onEscolherNivel;

  /// GAL-27 AC1: sem a capacidade de configurar o nível, o segmented **some
  /// da árvore**. A URL, a nota do nível vigente e o "COPIAR 🔗" ficam — quem
  /// não configura ainda convida.
  final bool podeConfigurarNivel;

  /// GAL-24 AC2 e `design.md` §14: festa sem código (criada antes de a spec 09
  /// gerar links) não tem URL para mostrar nem para copiar. O card continua na
  /// tela, o botão fica inerte, e **nenhuma copy nova** é inventada.
  bool get _temLink => convite.codigo.isNotEmpty;

  void _selecionar(int indice) {
    final nivel = NivelDoLink.values[indice];
    // GAL-28: tocar a opção já ativa não muda estado nem emite escrita.
    if (nivel == convite.nivel) return;
    onEscolherNivel(nivel);
  }

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      fundo: BoraColors.ink,
      acento: BoraAccent.purple,
      deslocamentoDaSombra: deslocamentoDaSombra,
      padding: BoraSpacing.cardHeroi,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            GaleraTextos.labelDoLink,
            style: BoraTextStyles.heroiLabel,
          ),
          if (_temLink) ...[
            SizedBox(height: vaoEntreBlocos),
            Text(
              GaleraTextos.urlDoConvite(convite.codigo),
              style: BoraTextStyles.linhaLista.copyWith(
                color: corDoTexto,
                decoration: TextDecoration.underline,
                decorationColor: corDoTexto,
              ),
            ),
          ],
          SizedBox(height: vaoEntreBlocos),
          BoraSecondaryButton(
            rotulo: GaleraTextos.copiar,
            fundoBranco: true,
            onPressed: _temLink ? onCopiar : null,
          ),
          SizedBox(height: vaoEntreBlocos),
          Text(
            GaleraTextos.quemAbrirPode,
            style: BoraTextStyles.labelSecao.copyWith(color: corDoTexto),
          ),
          if (podeConfigurarNivel) ...[
            SizedBox(height: vaoEntreBlocos),
            BoraSegmentedControl(
              opcoes: GaleraTextos.niveis,
              indiceAtivo: NivelDoLink.values.indexOf(convite.nivel),
              onSelecionar: _selecionar,
              sobreCardEscuro: true,
            ),
          ],
          SizedBox(height: vaoEntreBlocos),
          Text(
            GaleraTextos.notaDoNivel(convite.nivel),
            style: BoraTextStyles.dica.copyWith(color: corDoTexto),
          ),
        ],
      ),
    );
  }
}
