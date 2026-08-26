import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/observability/app_logger.dart';
import '../../domain/festa_repository.dart';
import '../../domain/resumo_de_festa.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

/// O estado da Home — HOME-09, HOME-10, HOME-15, HOME-16, HOME-19.
///
/// **Este bloc não navega** (AD-020 vale igual aqui): os toques da tela são
/// navegação comum, e quem chama `context.go` é a página.
///
/// Ele assina o stream na construção porque RN-28 exige que o contador mude
/// **sem refresh**: não há evento de "carregar" para a tela disparar, e não
/// haveria quem o disparasse quando a confirmação chegasse.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._festas, this._logger) : super(const HomeState()) {
    on<FestasRecebidas>(_aoReceberFestas);
    on<ObservacaoFalhou>(_aoFalhar);

    _inscricao = _festas.observarFestas().listen(
          (festas) => add(FestasRecebidas(festas)),
          onError: (Object erro, StackTrace stack) =>
              add(ObservacaoFalhou(erro, stack)),
        );
  }

  final FestaRepository _festas;
  final AppLogger _logger;

  late final StreamSubscription<List<ResumoDeFesta>> _inscricao;

  void _aoReceberFestas(FestasRecebidas evento, Emitter<HomeState> emit) {
    final chegando = [
      for (final festa in evento.festas)
        if (!festa.ehPassada) festa,
    ];
    final passadas = [
      for (final festa in evento.festas)
        if (festa.ehPassada) festa,
    ];

    emit(
      HomeState(
        situacao: evento.festas.isEmpty
            ? SituacaoDaHome.vazia
            : SituacaoDaHome.comFestas,
        chegando: chegando,
        passadas: passadas,
        comConfirmacaoNova: _confirmacoesNovas(chegando),
      ),
    );
  }

  /// **D-1**: quem ganhou confirmação em relação à emissão anterior.
  ///
  /// A primeira emissão nunca acusa confirmação nova — na primeira vez não há
  /// "anterior", e a Home abriria com o atalho do acerto aceso sem que nada
  /// tivesse acontecido.
  Set<String> _confirmacoesNovas(List<ResumoDeFesta> chegando) {
    if (state.situacao == SituacaoDaHome.carregando) return const {};

    final anteriores = {
      for (final festa in state.chegando) festa.festa.nome: festa.confirmados,
    };

    final nomesQueChegam = {for (final festa in chegando) festa.festa.nome};

    return {
      for (final festa in chegando)
        if ((anteriores[festa.festa.nome] ?? festa.confirmados) <
            festa.confirmados)
          festa.festa.nome,
      // Uma festa que já tinha o atalho aceso continua com ele: o anfitrião
      // não perde o caminho do acerto porque chegou outra emissão qualquer.
      //
      // **Podado pelo que está chegando agora**: sem isso o conjunto só
      // crescia, e uma festa nova com o nome de uma festa antiga já concluída
      // nasceria com o atalho aceso e zero confirmados — o contrário do que
      // P1-3 AC3 exige.
      ...state.comConfirmacaoNova.where(nomesQueChegam.contains),
    };
  }

  void _aoFalhar(ObservacaoFalhou evento, Emitter<HomeState> emit) {
    // AD-005: a falha vai para o logger e a tela mostra estado de erro. Tela
    // branca seria a única saída pior que as duas.
    _logger.logError(evento.erro, evento.stackTrace, name: 'home');

    // `copyWith`, e não estado zerado: o stream é broadcast e o erro **não**
    // cancela a inscrição, então o que já tinha chegado continua válido.
    // Zerando, uma falha passageira apagava as festas e o atalho do acerto de
    // uma confirmação que já tinha chegado — e a emissão seguinte, com o mesmo
    // número, não teria como reacendê-lo.
    emit(state.copyWith(situacao: SituacaoDaHome.falhou));
  }

  @override
  Future<void> close() async {
    await _inscricao.cancel();
    return super.close();
  }
}
