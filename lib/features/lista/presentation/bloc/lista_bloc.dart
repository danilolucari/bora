import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
import 'lista_event.dart';
import 'lista_state.dart';

export 'lista_event.dart';
export 'lista_state.dart';

/// A composição de uma festa que não existe — LIST-31.
///
/// Zero cabeças, e por isso a guarda de `CalculadoraDaFesta.calcular` devolve
/// lista vazia, total 0 e nenhum essencial. É o **mesmo caminho** de "festa
/// sem ninguém": um segundo caminho para o estado vazio poderia divergir dele.
///
/// A duração é a default do produto e não influencia nada: sem pessoas, o
/// fator de RN-02 não chega a multiplicar item nenhum.
final ComposicaoDaFesta _semNinguem = ComposicaoDaFesta(
  contagem: ContagemDePessoas(),
  duracaoHoras: 4,
);

/// O estado da tela Lista — LIST-10, LIST-31, LIST-32.
///
/// É o **único** lugar desta feature que chama `CalculadoraDaFesta.calcular` e
/// `faixaRealDaLista`. Nenhum widget faz conta: eles leem `state.resultado` e
/// `state.faixaReal` (LIST-07).
///
/// **Este bloc não navega** (AD-020): quem chama `context.go` é a página.
///
/// Assina `observarFesta` na construção, e continua assinado enquanto a tela
/// vive: outra aba da festa (`galera`, RN-21) pode mudar a composição com a
/// Lista viva no `indexedStack`.
class ListaBloc extends Bloc<ListaEvent, ListaState> {
  ListaBloc(
    this._festas,
    this._logger, {
    required String festaId,
  }) : super(const ListaState()) {
    on<FestaRecebida>(_aoReceberFesta);
    on<ObservacaoFalhou>(_aoFalharObservacao);
    on<ModoAlternado>(_aoAlternarModo);
    on<ItemExpandido>(_aoExpandirItem);

    _inscricao = _festas.observarFesta(festaId).listen(
          (festa) => add(FestaRecebida(festa)),
          onError: (Object erro, StackTrace stack) =>
              add(ObservacaoFalhou(erro, stack)),
        );
  }

  final FestaEmEdicaoRepository _festas;
  final AppLogger _logger;

  late final StreamSubscription<FestaEmEdicao?> _inscricao;

  /// A porta entregou a festa observada — LIST-31.
  void _aoReceberFesta(FestaRecebida evento, Emitter<ListaState> emit) {
    emit(_estadoCom(evento.festa));
  }

  /// O stream falhou — LIST-32.
  ///
  /// Loga (AD-005) e **não emite**: o último estado bom fica de pé. O stream
  /// da porta é broadcast e o erro não cancela a inscrição, então zerar aqui
  /// apagaria uma lista que continua válida — e a emissão seguinte, com o
  /// mesmo conteúdo, seria descartada pela igualdade e não a traria de volta.
  void _aoFalharObservacao(ObservacaoFalhou evento, Emitter<ListaState> emit) {
    _logger.logError(evento.erro, evento.stackTrace, name: 'lista');
  }

  /// O segmented mudou — LIST-01. **Não grava**: modo não é dado da festa.
  void _aoAlternarModo(ModoAlternado evento, Emitter<ListaState> emit) {
    emit(state.copyWith(modo: evento.modo));
  }

  /// Uma linha foi aberta ou fechada — LIST-10.
  ///
  /// `copyWith` não serve: ele resolve cada campo com `?? this.x`, então
  /// `ItemExpandido(null)` manteria o item aberto em vez de fechá-lo.
  void _aoExpandirItem(ItemExpandido evento, Emitter<ListaState> emit) {
    emit(
      ListaState(
        carregando: state.carregando,
        festa: state.festa,
        resultado: state.resultado,
        modo: state.modo,
        chaveExpandida: evento.chave,
        faixaReal: state.faixaReal,
        falhouAoSalvar: state.falhouAoSalvar,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _inscricao.cancel();
    return super.close();
  }

  /// O **único** ponto de cálculo da tela — LIST-07.
  ///
  /// Todo caminho que troca a festa termina aqui, e por isso não existe
  /// emissão que deixe `resultado` ou `faixaReal` para trás: é invariante do
  /// bloc, não disciplina de quem escrever o handler seguinte.
  ///
  /// Modo, item expandido e o aviso de falha **sobrevivem** ao recálculo: um
  /// item aberto continua aberto quando a lista recalcula (edge case da
  /// `spec.md`).
  ListaState _estadoCom(FestaEmEdicao? festa) {
    final resultado = CalculadoraDaFesta.calcular(
      festa?.composicao ?? _semNinguem,
    );

    return ListaState(
      carregando: false,
      festa: festa,
      resultado: resultado,
      modo: state.modo,
      chaveExpandida: state.chaveExpandida,
      faixaReal: _faixaDe(resultado),
      falhouAoSalvar: state.falhouAoSalvar,
    );
  }
}

/// A faixa real do rodapé, ou `null` com a lista vazia — LIST-09, LIST-31.
FaixaReal? _faixaDe(ResultadoDoCalculo resultado) =>
    resultado.todosOsItens.isEmpty
        ? null
        : faixaRealDaLista(resultado.todosOsItens, tabelaDePrecosDeMercado);
