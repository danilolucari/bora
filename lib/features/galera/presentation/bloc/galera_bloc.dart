import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/observability/app_logger.dart';
import '../../domain/chave_de_pessoa.dart';
import '../../domain/galera_da_festa.dart';
import '../../domain/galera_repository.dart';
import 'galera_event.dart';
import 'galera_state.dart';

export 'galera_event.dart';
export 'galera_state.dart';

/// O `name` de tudo o que este bloc registra no [AppLogger] (AD-005).
const String _nome = 'galera';

/// O estado da tela A GALERA — GAL-25, GAL-26, GAL-10.
///
/// **Um bloc só**, acima do `ResponsiveBuilder`: compacto e expandido são o
/// mesmo estado visto de dois jeitos (W-R1), e dois blocs divergiriam na
/// travessia dos 900px.
///
/// **Não navega** (AD-020, como o `HomeBloc` e o `ListaBloc`): quem chama
/// `context.go` é a página.
///
/// **Não calcula.** A aritmética de RN-03, RN-05 e RN-21 vive inteira em
/// `core/calculo` e é consumida pelos widgets a partir do registro que está
/// no estado (GAL-15 AC11).
///
/// Assina `observarGalera` **na construção**, e não por um evento de
/// "carregar": RN-28 exige que a confirmação que chega com a tela aberta
/// reflita sem refresh, e não haveria quem disparasse o evento nesse momento.
class GaleraBloc extends Bloc<GaleraEvent, GaleraState> {
  GaleraBloc(this._festaId, this._galera, this._logger)
      : super(const GaleraState()) {
    on<GaleraRecebida>(_aoReceberGalera);
    on<ObservacaoFalhou>(_aoFalhar);
    on<LinhaAlternada>(_aoAlternarLinha);

    _inscricao = _galera.observarGalera(_festaId).listen(
          (galera) => add(GaleraRecebida(galera)),
          onError: (Object erro, StackTrace stack) =>
              add(ObservacaoFalhou(erro, stack)),
        );
  }

  final String _festaId;
  final GaleraRepository _galera;
  final AppLogger _logger;

  late final StreamSubscription<GaleraDaFesta?> _inscricao;

  /// A porta entregou a galera — GAL-25.
  ///
  /// **Duas saídas, e cada uma tem o seu motivo:**
  ///
  /// - `null` ⇒ a festa **não existe**. Cai no mesmo `falhou`, e é
  ///   SPEC_PRECISION_GAP declarado (`design.md` §14): nenhuma tela de `04`
  ///   ou `06` desenha a Galera de uma festa inexistente, e inventar copy
  ///   própria seria pior que reusar a faixa de falha — o requisito que vale
  ///   (GAL-25) é "nunca tela branca". **Não registra no logger**: ausência de
  ///   dado não é exceção, e poluir o log de erro apagaria o sinal de GAL-25.
  /// - festa presente ⇒ `comFesta`, com a leitura no estado.
  ///
  /// **O painel aberto sobrevive à emissão** (GAL-26): a confirmação que chega
  /// com a tela aberta não fecha o accordion nem remonta a lista. É por isso
  /// que `aberta` é [ChaveDePessoa] e não índice — a pessoa nova pode entrar
  /// **antes** da aberta, e o índice passaria a apontar para outra linha.
  ///
  /// A única razão para fechar é a pessoa ter **sumido** do registro: sem
  /// linha, não há painel. Guarda distinta da de cima, e com sensor próprio.
  void _aoReceberGalera(GaleraRecebida evento, Emitter<GaleraState> emit) {
    final galera = evento.galera;

    if (galera == null) {
      emit(state.copyWith(situacao: SituacaoDaGalera.falhou));
      return;
    }

    final aberta = state.aberta;
    final continua =
        aberta != null && ChaveDePessoa.indiceEm(galera.pessoas, aberta) != null;

    emit(
      GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galera,
        aberta: continua ? aberta : null,
        copiasConcluidas: state.copiasConcluidas,
      ),
    );
  }

  /// Um card-linha foi tocado — GAL-10 AC1.
  ///
  /// **1 aberto por vez** por construção: `aberta` é um campo, não um
  /// conjunto, então abrir B fecha A sem que ninguém precise lembrar de
  /// fechar. Tocar a linha já aberta fecha, como em `BoraExpandableGroup`.
  void _aoAlternarLinha(LinhaAlternada evento, Emitter<GaleraState> emit) {
    emit(
      GaleraState(
        situacao: state.situacao,
        galera: state.galera,
        aberta: evento.chave == state.aberta ? null : evento.chave,
        copiasConcluidas: state.copiasConcluidas,
      ),
    );
  }

  /// O stream falhou — GAL-25.
  ///
  /// AD-005: a falha vai para o logger e a tela mostra estado de erro. Tela
  /// branca seria a única saída pior que as duas.
  ///
  /// `copyWith`, e não estado zerado: o stream não é cancelado pelo erro,
  /// então o que já tinha chegado continua válido. Zerando, uma falha
  /// passageira apagaria a galera inteira e o card do link junto — e
  /// `design.md` §10 promete o contrário, que o card e o CTA permanecem.
  void _aoFalhar(ObservacaoFalhou evento, Emitter<GaleraState> emit) {
    _logger.logError(evento.erro, evento.stackTrace, name: _nome);

    emit(state.copyWith(situacao: SituacaoDaGalera.falhou));
  }

  @override
  Future<void> close() async {
    await _inscricao.cancel();
    return super.close();
  }
}
