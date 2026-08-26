import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/resumo_de_festa.dart';
import '../home_textos.dart';

/// O card da festa que está chegando — T-02 e a coluna esquerda de W-02.
///
/// **Não navega.** Devolve os toques por callback: quem chama `context.go` é a
/// página. O card também não decide se o atalho do acerto aparece — quem sabe
/// que chegou confirmação nova é o `HomeBloc` (D-1), porque "nova" é
/// propriedade de duas emissões.
class CardDaFesta extends StatelessWidget {
  const CardDaFesta({
    required this.resumo,
    this.expandido = false,
    required this.aoConvidar,
    required this.aoMontarLista,
    required this.aoVerOAcerto,
    this.confirmacaoNova = false,
    super.key,
  });

  /// Quantos avatares a pilha mostra antes do "+N" — os R/A/L de T-02.
  static const int avataresVisiveis = 3;

  /// A copy literal de T-02.
  static const String convidar = '+ CONVIDAR';
  static const String montarLista = 'MONTAR LISTA →';
  static const String verOAcerto = '💸 VER O ACERTO DA FESTA →';

  /// T-02: "botões … (primário, flex 1.4)" — o par 1 : 1.4 em inteiros.
  static const int flexDoSecundario = 10;
  static const int flexDoPrimario = 14;

  /// §4, "card branco destacado": 6px em T-02 e a **variante forte** de 8px
  /// que W-02 pede. Lidos do token do card branco, e não do card-herói
  /// escuro: os dois valem 6 hoje, e são linhas independentes de §4 — quem
  /// mexesse na sombra do herói arrastaria a do card da Home junto.
  static double get distanciaDaSombra => BoraShadows.cardBranco.offset.dx;
  static double get distanciaDaSombraNoWeb =>
      BoraShadows.cardBrancoGrande.offset.dx;

  /// T-02 e W-02: "padding 28px" no web.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(20, 26, 20, 20);
  static const EdgeInsets paddingNoWeb = EdgeInsets.all(28);

  /// W-02: "título 38px" contra os 26px do papel de card de §2.
  static const double tamanhoDoTituloNoWeb = 38;

  // DEFERIDO: W-02 pede "avatares 40px empilhados" no web, e
  // `BoraStackedAvatars` é fixo no 34px de §5. Subir esse degrau é acrescentar
  // um parâmetro ao componente do design system — extensão que precisa de
  // emenda de fronteira própria, não de uma linha aqui. Os outros três
  // degraus de W-02 (sombra 8px, padding 28px, título 38px) estão aplicados.

  final ResumoDeFesta resumo;

  /// `true` ⇒ o degrau de W-02: sombra de 8px, padding de 28px, título de 38px
  /// e avatares de 40px. O design system é dono do papel; a spec de tela é
  /// dona do degrau — o mesmo critério de `BoraMarca` e do título da Home.
  final bool expandido;

  /// `true` ⇒ entra o atalho amarelo full-width do acerto (RN-28, T-02).
  final bool confirmacaoNova;

  final VoidCallback aoConvidar;
  final VoidCallback aoMontarLista;
  final VoidCallback aoVerOAcerto;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BoraSurface(
          acento: BoraAccent.ink,
          deslocamentoDaSombra:
              expandido ? distanciaDaSombraNoWeb : distanciaDaSombra,
          padding: expandido ? paddingNoWeb : padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resumo.festa.nome,
                style: expandido
                    ? BoraTextStyles.tituloCard.copyWith(
                        fontSize: tamanhoDoTituloNoWeb,
                      )
                    : BoraTextStyles.tituloCard,
                maxLines: 2,
                // W-R4: nome longo quebra ou trunca, e **nunca** produz scroll
                // horizontal.
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              // SPEC_PRECISION_GAP: T-02 desenha "avatares R/A/L" e não diz a
              // cor de cada um. `iniciais` carrega a letra, então a pilha
              // recebe a letra como nome e a cor sai de `avatarPairFor` — fica
              // dentro dos cinco pares de §1, mas não reproduz o pareamento
              // por persona. Reproduzi-lo exigiria o campo carregar o nome
              // inteiro, coisa que o `design.md` não pede.
              BoraStackedAvatars(
                // Capado no teto: sem isto a pilha desenhava **todas** as
                // iniciais e ainda somava o "+N" calculado sobre 3, mostrando
                // mais círculos do que gente confirmada.
                nomes: resumo.iniciais.take(avataresVisiveis).toList(),
                extras: resumo.excedenteDeAvatares(avataresVisiveis),
              ),
              const SizedBox(height: 12),
              _LinhaDeContadores(resumo: resumo),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: flexDoSecundario,
                    child: BoraSecondaryButton(
                      rotulo: convidar,
                      onPressed: aoConvidar,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: flexDoPrimario,
                    child: BoraPrimaryButton(
                      rotulo: montarLista,
                      onPressed: aoMontarLista,
                      larguraTotal: true,
                    ),
                  ),
                ],
              ),
              if (confirmacaoNova) ...[
                const SizedBox(height: 12),
                _AtalhoDoAcerto(onPressed: aoVerOAcerto),
              ],
            ],
          ),
        ),
        // §3: a tag de data vaza o topo do card — e **o vazamento é do
        // componente**, que já sobe os 13px sozinho. Repeti-lo aqui subia 26.
        Positioned(
          left: 16,
          top: 0,
          child: BoraRotatedTag(texto: resumo.festa.data, aEsquerda: false),
        ),
      ],
    );
  }
}

class _LinhaDeContadores extends StatelessWidget {
  const _LinhaDeContadores({required this.resumo});

  final ResumoDeFesta resumo;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        // T-02 mostra "2 pendentes" antes da confirmação e "1 pendente"
        // depois dela: as duas formas são copy da spec, não escolha.
        text: HomeTextos.contagem(resumo.confirmados, 'confirmado'),
        children: [
          const TextSpan(text: ' · '),
          TextSpan(
            // T-02 põe **só** os pendentes em vermelho: é o número que cobra
            // uma ação do anfitrião.
            text: HomeTextos.contagem(resumo.pendentes, 'pendente'),
            style: const TextStyle(color: BoraColors.primary),
          ),
        ],
      ),
      style: BoraTextStyles.linhaLista,
    );
  }
}

/// O atalho amarelo full-width de RN-28.
///
/// Composto com o [BoraPressSink] — o primitivo de §4 — em vez de um botão do
/// catálogo: o primário é `ink` e o secundário é claro, e nenhum dos dois é o
/// amarelo que T-02 pede aqui. Compor com o primitivo mantém borda, sombra e
/// afundamento vindos do design system, sem cor nova no sistema.
class _AtalhoDoAcerto extends StatelessWidget {
  const _AtalhoDoAcerto({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BoraPressSink(
        acento: BoraAccent.ink,
        fundo: BoraColors.yellow,
        padding: BoraSpacing.botao,
        onPressed: onPressed,
        child: Text(
          CardDaFesta.verOAcerto,
          textAlign: TextAlign.center,
          style: BoraTextStyles.botao.copyWith(color: BoraColors.ink),
        ),
      ),
    );
  }
}
