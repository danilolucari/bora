import 'package:flutter/widgets.dart';

import '../../../../core/design_system/design_system.dart';

/// Qual dos dois campos de identidade está aberto para edição.
enum _CampoEmEdicao { nome, data }

/// O bloco de identidade do rolê no header: nome e data, editáveis **na
/// própria tela** — MONT-15 (A-03).
///
/// Fora de edição os dois são texto. Acionado, o campo vira um
/// [BoraTextField] no mesmo lugar: nenhuma navegação, nenhuma tela nova,
/// nenhum diálogo. É o que A-03 pede — o rolê ganha nome e data sem que
/// exista tela para isso em spec nenhuma.
///
/// **O widget não guarda o valor como verdade.** Ele exibe [nome] e [data],
/// que vêm do bloc, e devolve o que foi confirmado por [aoAlterarNome] e
/// [aoAlterarData]. Confirmar não muda o texto exibido: quem muda é o estado
/// que volta de cima. Nome vazio é emitido **vazio** — quem devolve o default
/// é o bloc, e a divisão é de propósito: o header não conhece o nome padrão do
/// produto.
///
/// **Confirmar é sair do campo.** O [BoraTextField] da spec 01 não expõe
/// callback de submissão, e a spec 05 não pode tocar o design system — então a
/// confirmação é a saída do foco, que é como um rótulo editável se comporta:
/// o anfitrião escreve e toca em outro lugar. Duas consequências, e as duas
/// são testadas:
///
/// - **nada do que foi digitado se perde**: sair confirma, em vez de descartar;
/// - **edição que não mudou nada não grava**: abrir o campo e sair sem
///   escrever não emite evento nenhum. Sem essa guarda, encostar no nome de um
///   rascunho criaria a festa (MONT-17) sem o anfitrião ter mudado coisa
///   alguma.
class CabecalhoDoRole extends StatefulWidget {
  const CabecalhoDoRole({
    required this.nome,
    required this.data,
    required this.aoAlterarNome,
    required this.aoAlterarData,
    super.key,
  });

  /// As chaves pelas quais a tela e o teste acionam cada metade.
  static const Key chaveDoNome = Key('cabecalho-do-role-nome');
  static const Key chaveDaData = Key('cabecalho-do-role-data');
  static const Key chaveDoCampoDoNome = Key('cabecalho-do-role-campo-nome');
  static const Key chaveDoCampoDaData = Key('cabecalho-do-role-campo-data');

  /// *SPEC_PRECISION_GAP*: nenhuma tela de `04`/`06` desenha a edição do nome
  /// e da data, e nenhuma spec dá placeholder para elas. Os dois seguem a
  /// forma de §5 ("placeholder em minúsculas") e ficam declarados como
  /// default, não como literal de spec.
  static const String placeholderDoNome = 'nome do rolê';
  static const String placeholderDaData = 'data do rolê';

  /// O nome do rolê, como o bloc o tem agora.
  final String nome;

  /// A data do rolê — rótulo livre, nunca `DateTime` (A-23).
  final String data;

  /// Emitido ao confirmar o nome, **sem transformação**: vazio sai vazio.
  final void Function(String nome) aoAlterarNome;

  /// Emitido ao confirmar a data, em CAIXA ALTA (§7 do arquivo 02).
  final void Function(String data) aoAlterarData;

  @override
  State<CabecalhoDoRole> createState() => _CabecalhoDoRoleState();
}

class _CabecalhoDoRoleState extends State<CabecalhoDoRole> {
  _CampoEmEdicao? _emEdicao;
  TextEditingController? _controller;
  FocusNode? _foco;

  /// O valor que o campo tinha ao abrir — a régua do "mudou ou não mudou".
  String _valorAoAbrir = '';

  @override
  void dispose() {
    _soltarCampo()?.call();
    super.dispose();
  }

  void _abrir(_CampoEmEdicao campo, String valorAtual) {
    final descarte = _soltarCampo();
    final controller = TextEditingController(text: valorAtual);
    final foco = FocusNode();
    foco.addListener(_aoMudarOFoco);

    setState(() {
      _emEdicao = campo;
      _valorAoAbrir = valorAtual;
      _controller = controller;
      _foco = foco;
    });

    _agendarDescarte(descarte);

    // O campo nasce com o foco: acionar o rótulo é começar a escrever.
    foco.requestFocus();
  }

  void _aoMudarOFoco() {
    if (_foco?.hasFocus ?? false) return;
    _confirmar();
  }

  void _confirmar() {
    final campo = _emEdicao;
    final texto = _controller?.text;
    if (campo == null || texto == null) return;

    final descarte = _soltarCampo();

    // Fecha **antes** de emitir: o callback pode reconstruir a árvore, e o
    // campo já tem de estar fora dela quando isso acontecer.
    setState(() => _emEdicao = null);
    _agendarDescarte(descarte);

    // Edição que não mudou nada não grava — ver o doc da classe.
    if (texto == _valorAoAbrir) return;

    switch (campo) {
      // Sem `trim` e sem default: o vazio é informação, e é o bloc quem sabe
      // o nome padrão do produto (P1-5 AC6).
      case _CampoEmEdicao.nome:
        widget.aoAlterarNome(texto);
      case _CampoEmEdicao.data:
        widget.aoAlterarData(texto.toUpperCase());
    }
  }

  /// Solta o campo aberto e devolve como descartá-lo, ou `null` se não havia
  /// nenhum.
  ///
  /// O `dispose` **não** acontece aqui: o controller e o nó de foco ainda
  /// estão presos ao `TextField` do quadro corrente, e liberá-los agora — no
  /// meio do próprio listener de foco — usaria objeto morto na reconstrução.
  VoidCallback? _soltarCampo() {
    final controller = _controller;
    final foco = _foco;
    if (controller == null || foco == null) return null;

    foco.removeListener(_aoMudarOFoco);
    _controller = null;
    _foco = null;

    return () {
      controller.dispose();
      foco.dispose();
    };
  }

  void _agendarDescarte(VoidCallback? descarte) {
    if (descarte == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => descarte());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_emEdicao == _CampoEmEdicao.nome)
          _campo(
            chave: CabecalhoDoRole.chaveDoCampoDoNome,
            placeholder: CabecalhoDoRole.placeholderDoNome,
          )
        else
          _rotulo(
            chave: CabecalhoDoRole.chaveDoNome,
            texto: widget.nome,
            estilo: BoraTextStyles.linhaLista,
            aoAcionar: () => _abrir(_CampoEmEdicao.nome, widget.nome),
          ),
        SizedBox(height: BoraSpacing.chip.top),
        if (_emEdicao == _CampoEmEdicao.data)
          _campo(
            chave: CabecalhoDoRole.chaveDoCampoDaData,
            placeholder: CabecalhoDoRole.placeholderDaData,
          )
        else
          _rotulo(
            chave: CabecalhoDoRole.chaveDaData,
            texto: widget.data,
            estilo: BoraTextStyles.labelSecao,
            aoAcionar: () => _abrir(_CampoEmEdicao.data, widget.data),
          ),
      ],
    );
  }

  Widget _rotulo({
    required Key chave,
    required String texto,
    required TextStyle estilo,
    required VoidCallback aoAcionar,
  }) =>
      GestureDetector(
        key: chave,
        // O alvo é a linha inteira, não só os glifos.
        behavior: HitTestBehavior.opaque,
        onTap: aoAcionar,
        child: Text(texto, style: estilo),
      );

  Widget _campo({required Key chave, required String placeholder}) =>
      BoraTextField(
        key: chave,
        controller: _controller!,
        focusNode: _foco,
        placeholder: placeholder,
      );
}
