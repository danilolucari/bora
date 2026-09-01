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

/// O stepper de "QUANTIDADE" de um item foi acionado — LIST-11.
///
/// [passos] é ±1 por toque. O **passo** e o **piso** são os do catálogo, e
/// quem os aplica é `comPassoDeQuantidade` de `core/calculo` (RN-12): 0,5 kg
/// nas carnes, 2 latas na cerveja, 1 nos demais, nunca abaixo de um passo.
class QuantidadeAjustada extends ListaEvent {
  const QuantidadeAjustada(this.chave, this.passos);

  final ChaveItem chave;
  final int passos;
}

/// O stepper de "PREÇO" de um item foi acionado — LIST-11.
///
/// [passos] é ±1 por toque, e cada passo vale R$ 1, com mínimo de R$ 1 —
/// aplicados por `comPassoDePreco` (RN-12).
class PrecoAjustado extends ListaEvent {
  const PrecoAjustado(this.chave, this.passos);

  final ChaveItem chave;
  final int passos;
}

/// O "RESTAURAR" do rodapé — LIST-14.
///
/// Desfaz **todos** os ajustes de uma vez, sem diálogo e sem toast (UC-06 A1).
class OverridesRestaurados extends ListaEvent {
  const OverridesRestaurados();
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

/// Uma gravação na porta falhou — interno, LIST-32.
///
/// Acende `falhouAoSalvar` e **não reverte** o que está na tela: o requisito
/// literal é "não perde o estado da tela nem trava a interação".
class GravacaoFalhou extends ListaEvent {
  const GravacaoFalhou(this.erro, this.stackTrace);

  final Object erro;
  final StackTrace stackTrace;
}
