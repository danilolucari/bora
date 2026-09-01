import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
import 'lista_state.dart';

/// Os eventos da tela Lista.
///
/// **O bloc não navega** (AD-020, como em `HomeBloc` e `MontarBloc`): quem
/// chama `context.go` é a página.
sealed class ListaEvent {
  const ListaEvent();
}

/// O segmented "🧮 PLANEJAR / 🛒 COMPRAR" mudou — LIST-01.
///
/// Estado de UI puro: **não grava na porta**. Trocar de modo não é editar a
/// festa.
class ModoAlternado extends ListaEvent {
  const ModoAlternado(this.modo);

  final ModoDaLista modo;
}

/// Uma linha do modo PLANEJAR foi tocada — LIST-10.
///
/// [chave] `null` fecha o que estiver aberto. Abrir um item fecha o anterior
/// por construção, porque o estado guarda **um** campo e não um conjunto.
class ItemExpandido extends ListaEvent {
  const ItemExpandido(this.chave);

  final ChaveItem? chave;
}

/// A porta emitiu a festa observada — interno, LIST-31.
///
/// `null` = a festa não existe. A rota continua válida: a tela abre vazia e
/// coerente, sem redirecionar para `/erro`.
class FestaRecebida extends ListaEvent {
  const FestaRecebida(this.festa);

  final FestaEmEdicao? festa;
}

// SPEC_DEVIATION: `design.md` §7.1 previa **um** evento interno de falha,
// `PersistenciaFalhou(Object, StackTrace)`, para leitura e gravação.
// Reason: os dois caminhos têm tratamento diferente por spec. A falha do
// stream mantém o último estado bom e **não** acende `falhouAoSalvar` (§10,
// linha "Stream de `observarFesta` falha"), enquanto a falha de gravação
// acende (LIST-32). Um evento só obrigaria o handler a adivinhar qual dos
// dois aconteceu.

/// O stream de `observarFesta` falhou — interno, LIST-32.
///
/// Loga e **mantém o último estado bom**: o que já tinha chegado continua
/// válido, e a tela não pisca.
class ObservacaoFalhou extends ListaEvent {
  const ObservacaoFalhou(this.erro, this.stackTrace);

  final Object erro;
  final StackTrace stackTrace;
}
